class NotificationsController < ApplicationController

  before_action :load_user, only: :index
  before_action :delete_read_notifications, only: :index
  before_action :load_notification, only: [:destroy, :update]

  authorize_resource

  def index
    @notifications = @user.my_notifications.reverse
  end

  def destroy
    if @notification.destroy
      render :destroy
    else
      render "errors/failed", status: 400
    end
  end

  def update
    unless @notification.was_read
      @notification.was_read = true
      @notification.save
    end
  end

  private

  def load_user
    owner_id = params[:owner_name] || params[:user_id]
    @user = User.find owner_id
  end

  def delete_read_notifications
    @user.my_notifications.each do |notificaion|
      if notificaion.was_read_before 1.hour
        notificaion.delete
      end
    end
  end

  def load_notification
    @notification = Notification.find params[:id]
  end

  def notification_params
    if params[:notificaion]
      params.require(:notification).permit Notification.updatable_columns
    end
  end
end
