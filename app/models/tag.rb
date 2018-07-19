# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#  user_id    :integer
#
# Indexes
#
#  fk_rails_2f90b9163e  (project_id)
#  index_tags_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...     (project_id => projects.id)
#  fk_tags_user_id  (user_id => users.id)
#

class Tag < ActiveRecord::Base
  include Contributable

  belongs_to :user, required: true
  belongs_to :project, required: true

  concerning :Draft do
    def generate_draft
      name.to_s
    end
  end

  class << self
    def updatable_columns
      [:_destroy, :name, :user_id]
    end
  end
end
