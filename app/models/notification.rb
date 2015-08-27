class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :notifier, class_name: "User", inverse_of: :notifications_given
  belongs_to :notified, class_name: "User", inverse_of: :my_notifications

  validates :notifier, :notified, :notificatable_url, :notificatable_type, :body, presence: true

  field :notificatable_url, type: String
  field :notificatable_type, type: String
  field :body, type: String
  field :was_read, type: Boolean, default: false

  def was_read_before time
    if self.was_read and Time.now - self.updated_at > time
      return true
    end
    return false
  end
end
