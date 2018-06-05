class ChecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_check, except: [:index, :new, :create]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @checks = policy_scope(Check).order(:domain_expires_at)
  end

  def new
    @check = Check.new
    build_empty_notification
    authorize @check
  end

  def create
    @check = Check.new(new_check_params)
    @check.user = current_user
    authorize @check

    if @check.save
      flash[:notice] = "Your check has been saved."
      redirect_to checks_path
    else
      flash.now[:alert] = "An error occured."
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
    params.require(:check).permit(:domain, :domain_created_at, :comment, :vendor, *others,
      notifications_attributes: [:id, :channel, :recipient, :delay])
  end

  def build_empty_notification
    @check.notifications.build
  end
end
