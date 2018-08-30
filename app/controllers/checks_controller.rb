# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class ChecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_check, except: [:index, :new, :create]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  has_scope :kind
  has_scope :by_domain
  has_scope :recurrent_failures, type: :boolean do |_controller, scope, _value|
    scope.consecutive_failures(Rails.configuration.chexpire.interface.consecutive_failures_as_error)
  end

  def index
    @checks = apply_scopes(policy_scope(Check)).order(Hash[*current_sort]).page(params[:page])
  end

  def new
    @check = Check.new
    authorize @check

    if params[:kind].present?
      return not_found unless Check.kinds.key?(params[:kind])
      @check.kind = params[:kind]
    end

    build_empty_notification
  end

  def create # rubocop:disable Metrics/AbcSize
    @check = Check.new(new_check_params.merge(user: current_user))
    authorize @check

    if @check.save
      flash[:notice] = t("checks.created", scope: :flashes)
      redirect_to checks_path
    else
      flash.now[:alert] = t("checks.invalid", scope: :flashes)

      fill_or_build_new_notification
      render :new
    end
  end

  def edit
    build_empty_notification
  end

  def update
    if @check.update(update_check_params)
      flash[:notice] = t("checks.updated", scope: :flashes)
      redirect_to checks_path
    else
      flash.now[:alert] = t("checks.invalid", scope: :flashes)

      fill_or_build_new_notification
      render :edit
    end
  end

  def destroy
    @check.destroy!

    flash[:notice] = t("checks.destroyed", scope: :flashes)
    redirect_to checks_path
  end

  private

  def set_check
    @check = Check.find(params[:id])
    authorize @check
  end

  def new_check_params
    check_params(:kind)
  end

  def update_check_params
    check_params(:active)
  end

  def check_params(*others)
    permitted_params = params.require(:check)
                             .permit(:domain, :domain_created_at, :comment, :vendor, :round_robin, *others,
                             notification_ids: [],
                             notifications_attributes: [:channel, :label, :recipient, :interval])

    permitted_params[:notifications_attributes].each_pair do |_key, attributes|
      attributes.merge!(user: current_user)
    end

    permitted_params
  end

  def build_empty_notification
    @new_notification = @check.notifications.build
    @new_notification.recipient = current_user.email
  end

  def fill_or_build_new_notification
    last_notification = @check.notifications.last

    # user has filled a new notification: we use it for the form
    if last_notification.new_record?
      @new_notification = last_notification
    else # otherwise, set a new empty notification
      build_empty_notification
    end
  end

  def current_sort
    @current_sort ||= clean_sort || Check.default_sort
  end
  helper_method :current_sort

  def clean_sort
    return unless params[:sort].present?
    field, _, direction = params[:sort].rpartition("_").map(&:to_sym)

    valid_fields = [:domain, :domain_expires_at]
    valid_directions = [:asc, :desc]

    return unless valid_fields.include?(field)
    return unless valid_directions.include?(direction)

    [field, direction]
  end
end
