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

class ProjectAccessLog < ApplicationRecord
  belongs_to :project, counter_cache: :project_access_logs_count
  belongs_to :user, optional: true

  ONE_MONTH = 30

  def self.log!(project, user)
    if user
      # プロジェクト管理者の場合はログしない
      return if user.is_project_manager?(project)

      # ログは1ユーザーにつき1プロジェクト1日1回
      return if where(user: user, project: project).where(created_at: DateTime.current.all_day).exists?
    end

    create!(project: project, user: user)
  end

  def self.log_last_days!(project, total, days: ONE_MONTH)
    if total < days
      total.downto(1) do |i|
        create!(project: project, created_at: DateTime.current - i.day)
      end
    else
      count_per_day = (total / days).round
      days.downto(1) do |i|
        count_per_day.times do
          create!(project: project, created_at: DateTime.current - i.day)
        end
      end
    end
  end
end
