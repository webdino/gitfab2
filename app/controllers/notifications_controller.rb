class NotificationsController < ApplicationController
  def index
    delete_read_notifications
    @notifications = current_user.my_notifications.order(id: :desc)
  end

  def update
    notification = current_user.my_notifications.find(params[:id])
    notification.update(was_read: true) unless notification.was_read
    render body: nil
  end

  def mark_all_as_read
    current_user.my_notifications.update_all(was_read: true)
    render json: {}
  end

  private

    def delete_read_notifications
      current_user.my_notifications.each do |notification|
        notification.delete if notification.was_read_before 1.hour
      end
    end
end
