class Notification < ActiveRecord::Base

  belongs_to :notifier, class_name: 'User', inverse_of: :notifications_given
  belongs_to :notified, class_name: 'User', inverse_of: :my_notifications

  validates :notifier, :notified, :notificatable_url, :notificatable_type, :body, presence: true

  def was_read_before(time)
    return true if was_read && Time.zone.now - updated_at > time
    false
  end
end
