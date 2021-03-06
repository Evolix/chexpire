# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)
# == Schema Information
#
# Table name: checks
#
#  id                   :bigint(8)        not null, primary key
#  active               :boolean          default(TRUE), not null
#  comment              :string(255)
#  consecutive_failures :integer          default(0), not null
#  domain               :string(255)      not null
#  domain_created_at    :datetime
#  domain_expires_at    :datetime
#  domain_updated_at    :datetime
#  kind                 :integer          not null
#  last_run_at          :datetime
#  last_success_at      :datetime
#  mode                 :integer          default("auto"), not null
#  round_robin          :boolean          default(TRUE)
#  vendor               :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint(8)
#
# Indexes
#
#  index_checks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Check < ApplicationRecord
  belongs_to :user
  has_many :logs, class_name: "CheckLog", dependent: :destroy
  has_many :check_notifications, dependent: :destroy
  has_many :notifications, -> { order(checks_count: :desc) },
                          through: :check_notifications, validate: true

  accepts_nested_attributes_for :notifications,
    reject_if: lambda { |att| att["interval"].blank? }

  enum kind: [:domain, :ssl]
  enum mode: [:auto, :manual]

  # Those dates are written as UTC,
  # but not converted back when read from the database
  self.skip_time_zone_conversion_for_attributes = [
    :domain_created_at,
    :domain_updated_at,
    :domain_expires_at,
  ]

  validates :kind, presence: true
  validates :domain, presence: true
  validate :domain_created_at_past
  validate :domain_updated_at_past
  validates :domain_expires_at, presence: true, unless: :supported?
  validates :comment, length: { maximum: 255 }
  validates :vendor, length: { maximum: 255 }

  before_save :reset_consecutive_failures
  before_save :set_mode
  after_update :reset_check_notifications
  after_save :enqueue_sync

  scope :active, -> { where(active: true) }
  scope :last_run_failed, -> {
    where("(last_success_at IS NULL AND last_run_at IS NOT NULL)
      OR (last_success_at <= DATE_SUB(last_run_at, INTERVAL 5 MINUTE))")
  }

  scope :kind, ->(kind) { where(kind: kind) }
  scope :by_domain, ->(domain) { where("domain LIKE ?", "%#{domain}%") }
  scope :consecutive_failures, ->(consecutive) {
    where("consecutive_failures >= ?", consecutive)
  }

  def self.default_sort
    [:domain_expires_at, :asc]
  end

  def days_from_last_success
    return unless last_success_at.present?

    # return the number of whole days
    ((Time.now - last_success_at) / (24 * 3600)).to_i
  end

  def increment_consecutive_failures!
    self.consecutive_failures += 1
    save!(validate: false)
  end

  def supported?
    return true unless domain?
    return true if domain.blank?

    begin
      Whois::Parser.for(domain)
      true
    rescue Whois::UnsupportedDomainError
      false
    rescue StandardError
      false
    end
  end

  def domain_expires_in_days
    Integer(domain_expires_at.to_date - Time.now.utc.to_date)
  end

  private

  def domain_created_at_past
    errors.add(:domain_created_at, :past) if domain_created_at.present? && domain_created_at.future?
  end

  def domain_updated_at_past
    errors.add(:domain_updated_at, :past) if domain_updated_at.present? && domain_updated_at.future?
  end

  def enqueue_sync
    return unless active?
    return unless saved_changes.key?("domain")

    ResyncJob.perform_later(id)
  end

  def reset_check_notifications
    return unless (saved_changes.keys & %w[domain domain_expires_at]).present?

    check_notifications.each(&:reset!)
  end

  def reset_consecutive_failures
    return unless last_success_at_changed? || mode_changed? || domain_changed?
    return if consecutive_failures_changed?

    self.consecutive_failures = 0
  end

  def set_mode
    return unless domain_changed?
    self.mode = supported? ? :auto : :manual
  end
end
