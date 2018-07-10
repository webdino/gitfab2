# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                 :integer          not null, primary key
#  body               :string(255)
#  notificatable_type :string(255)
#  notificatable_url  :string(255)
#  oldid              :string(255)
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


FactoryBot.define do
  factory :notification do
    association :notifier, factory: :user
    association :notified, factory: :user
    notificatable_url "https://example.com"
    notificatable_type { Project.name }
    body "notification body"
    was_read false
  end
end
