# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, except: [:index, :new, :create]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @notifications = policy_scope(Notification).order(checks_count: :desc)
  end

  def new;
    @notification = Notification.new
    authorize @notification
    @notification.recipient = current_user.email
  end

  def create
    @notification = Notification.new(notification_params)
    @notification.user = current_user
    authorize @notification

    if @notification.save
      flash[:notice] = t("notifications.created", scope: :flashes)
      redirect_to notifications_path
    else
      flash.now[:alert] = t("notifications.invalid", scope: :flashes)
      render :new
    end
  end


  def edit; end

  def update
    if @notification.update(notification_params)
      flash[:notice] = t("notifications.updated", scope: :flashes)
      redirect_to notifications_path
    else
      flash.now[:alert] = t("notifications.error", scope: :flashes)
      render :edit
    end
  end

  def destroy
    @notification.destroy!

    flash[:notice] = t("notifications.destroyed", scope: :flashes)
    redirect_to notifications_path
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
    authorize @notification
  end

  def notification_params
    params.require(:notification).permit(:label, :recipient, :interval)
  end
end
