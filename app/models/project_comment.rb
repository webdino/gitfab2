# == Schema Information
#
# Table name: project_comments
#
#  id         :bigint(8)        not null, primary key
#  body       :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_project_comments_on_project_id  (project_id)
#  index_project_comments_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#

class ProjectComment < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :body, presence: true, length: { maximum: 300 }
end
