# == Schema Information
#
# Table name: project_access_statistics
#
#  id           :bigint(8)        not null, primary key
#  access_count :integer          default(0), not null
#  date_on      :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  project_id   :integer          not null
#
# Indexes
#
#  index_project_access_statistics_on_date_on_and_project_id  (date_on,project_id)
#  index_project_access_statistics_on_project_id              (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#

FactoryBot.define do
  factory :project_access_statistic do
    date_on { rand(0..7).days.ago.to_date }
    association :project, factory: %i[project public]
    access_count { rand(10000) }
  end
end
