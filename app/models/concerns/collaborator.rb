module Collaborator
  extend ActiveSupport::Concern
  included do
    embeds_many :collaborations, as: :owner

    def is_collaborator_of?(project)
      collaborations.where(project_id: project.id).exists?
    end

    def collaboration_in(project)
      collaborations.find_by project_id: project.id
    end

    def collaborate!(project)
      collaborations.create project: project
    end
  end
end
