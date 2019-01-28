# == Schema Information
#
# Table name: black_lists
#
#  id                          :bigint(8)        not null, primary key
#  reason(理由)                  :text(65535)      not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  project_id(ブラックリスト対象プロジェクト) :integer          not null
#  user_id(登録した管理者)            :integer          not null
#
# Indexes
#
#  index_black_lists_on_project_id  (project_id)
#  index_black_lists_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :black_list do
    project { nil }
    user { nil }
    reason { "MyString" }
  end
end
