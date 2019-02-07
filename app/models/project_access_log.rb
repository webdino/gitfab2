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
  belongs_to :project
  belongs_to :user, optional: true

  def self.log!(project, user, created_on = Date.current)
    # プロジェクト管理者の場合はログしない
    return if user&.is_project_manager?(project)

    # ログは1ユーザーにつき1日1回
    return if where(user: user).where("DATE(created_at) = ?", created_on).exists?

    create!(project: project, user: user)
  end
end
