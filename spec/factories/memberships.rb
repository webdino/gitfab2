# frozen_string_literal: true
# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  role       :string(255)      default("editor")
#  created_at :datetime
#  updated_at :datetime
#  group_id   :integer
#  user_id    :integer
#
# Indexes
#
#  index_users_on_group_id_user_id  (group_id,user_id) UNIQUE
#

FactoryBot.define do
  factory :membership do
    user
    group
    role 'admin'
  end
end
