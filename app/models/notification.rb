# == Schema Information
#
# Table name: notifications
#
#  id                 :integer          not null, primary key
#  body               :string(255)
#  notificatable_type :string(255)
#  notificatable_url  :string(255)
#  was_read           :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  notified_id        :integer
#  notifier_id        :integer
#
# Indexes
#
#  index_notifications_on_notified_id  (notified_id)
#  index_notifications_on_notifier_id  (notifier_id)
#
# Foreign Keys
#
#  fk_notifications_notified_id  (notified_id => users.id)
#  fk_notifications_notifier_id  (notifier_id => users.id)
#

class Notification < ApplicationRecord

  belongs_to :notifier, class_name: 'User', inverse_of: :notifications_given, required: true
  belongs_to :notified, class_name: 'User', inverse_of: :my_notifications, required: true

  validates :notificatable_url, :notificatable_type, :body, presence: true

  def was_read_before(time)
    return true if was_read && Time.zone.now - updated_at > time
    false
  end
end
