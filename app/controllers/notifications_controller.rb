# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, except: [:create]

  def create
    check = Check.find(params[:check_id])
    @notification = check.notifications.build(notification_params)
    authorize @notification

    if @notification.save
      flash[:notice] = "Your notification has been saved."
      redirect_to check_path
    else
      flash.now[:alert] = "An error occured."
      render "checks/edit"
    end
  end

  def destroy
    @notification.destroy!

    respond_to do |format|
      format.js
    end
  end

  private

  def set_notification
    # joins the check because policy use the check relation
    @notification = Notification
                    .joins(:check)
                    .find_by!(id: params[:id], check_id: params[:check_id])
    authorize @notification
  end

  def notification_params
    params.require(:notification).permit(:channel, :recipient, :interval)
  end

  def check_path
    edit_check_path(check_id: params[:check_id])
  end
end
