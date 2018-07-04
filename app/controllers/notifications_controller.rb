class NotificationsController < ApplicationController
  before_action :load_user, only: [:index, :mark_all_as_read]
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
      render json: { success: false }, status: 400
    end
  end

  def update
    unless @notification.nil? && @notification.was_read
      @notification.was_read = true
      @notification.save
    end
    render body: nil
  end

  def mark_all_as_read
    @user.my_notifications.each do |notification|
      notification.was_read = true
      notification.save
    end
  end

  private

  def load_user
    owner_id = params[:owner_name] || params[:user_id]
    @user = User.friendly.find owner_id
  end

  def delete_read_notifications
    @user.my_notifications.each do |notification|
      notification.delete if notification.was_read_before 1.hour
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
