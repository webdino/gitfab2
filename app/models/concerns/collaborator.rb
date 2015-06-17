module Collaborator
  extend ActiveSupport::Concern
  included do
    embeds_many :collaborations, as: :owner

    def is_collaborator_of? project
      collaborations.where(project_id: project.id).exists?
    end

    def is_in_collaborated_group? project
      is_in_collaborated_group = false
      project.collaborators.each do |collaborator|
        if collaborator.class.name == Group.name
          is_in_collaborated_group = is_in_collaborated_group || self.is_member_of?(collaborator)
        end
      end
    end

    def collaboration_in project
      collaborations.find_by project_id: project.id
    end

    def collaborate! project
      collaborations.create project: project
    end
  end
end
