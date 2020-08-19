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
#  index_project_access_statistics_on_date_on_and_project_id  (date_on,project_id) UNIQUE
#  index_project_access_statistics_on_project_id              (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#

class ProjectAccessStatistic < ApplicationRecord
  belongs_to :project

  def self.access_ranking(from: 1.month.ago.to_date, to: Time.current.to_date)
    Project.joins(:project_access_statistics).group(:project_id).where(project_access_statistics: { date_on: from .. to }).select("projects.*, SUM(project_access_statistics.access_count) AS access_count").order(Arel.sql("access_count DESC"))
  end
end
