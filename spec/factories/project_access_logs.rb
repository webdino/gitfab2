# == Schema Information
#
# Table name: project_access_logs
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer          not null
#  user_id    :integer
#
# Indexes
#
#  index_project_access_logs_on_project_id  (project_id)
#  index_project_access_logs_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :project_access_log do
    project
    user
  end
end
