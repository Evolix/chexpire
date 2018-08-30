# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class ChecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_check, except: [:index, :new, :create, :supports]
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

  def create
    @check = Check.new(new_check_params)
    @check.user = current_user
    authorize @check

    if @check.save
      flash[:notice] = t(".saved")
      redirect_to checks_path
    else
      flash.now[:alert] = t(".invalid")
      render :new
    end
  end

  def edit
    build_empty_notification
  end

  def update
    if @check.update(update_check_params)
      flash[:notice] = "Your check has been updated."
      redirect_to checks_path
    else
      flash.now[:alert] = "An error occured."
      build_empty_notification
      render :edit
    end
  end

  def destroy
    @check.destroy!

    flash[:notice] = "Your check has been destroyed."
    redirect_to checks_path
  end

  def supports
    @check = Check.new(new_check_params)
    authorize @check
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
    params.require(:check)
          .permit(:domain, :domain_expires_at, :comment, :vendor, :round_robin, *others,
                  notifications_attributes: [:id, :channel, :recipient, :interval])
  end

  def build_empty_notification
    @check.notifications.build
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
