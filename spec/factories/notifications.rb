# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    notifier nil
    notified nil
    notificatable_url nil
    notificatable_type nil
    body nil
    was_read false
  end
end
