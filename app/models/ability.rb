class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new
    can :manage, User, id: user.id
    can :manage, Membership do |membership|
      user.is_admin_of?(membership.group) || user == membership.user
    end
    can :create, Card::Usage do |card|
      user.persisted?
    end
    can :manage, Card::Usage do |card|
      card.project && (user.is_contributor_of?(card) || is_project_editor?(card.project, user))
    end
    can :create, Card::Annotation do |card|
      user.persisted?
    end
    can :manage, Card::Annotation do |card|
      user.is_contributor_of?(card) || can?(:manage, card.annotatable)
    end
    can :manage, Card::RecipeCard do |card|
      card.recipe && is_project_editor?(card.recipe.project, user)
    end
    can :manage, Card::NoteCard do |card|
      card.note && is_project_editor?(card.note.project, user)
    end
    can :manage, Project do |project|
      is_project_manager?(project, user)
    end
    can :edit, Project do |project|
      is_project_editor?(project, user)
    end
    can :read, Project do |project|
      !project.is_private? ? true : is_project_editor?(project, user)
    end
    can :read, Note do |note|
      can? :read, note.project
    end
    can :update, Recipe do |recipe|
      if recipe.owner_type == Group.name
        user.is_member_of? recipe.owner
      end
    end
    can :read, Recipe do |recipe|
      can? :read, recipe.project
    end
    can :manage, Attachment do |pa|
      can? :update, pa.recipe
    end
    can :manage, Collaboration do |collabo|
      can? :manage, collabo.project
    end
    can :create, Comment do
      user.persisted?
    end
    can [:update, :destroy], Comment do |comment|
      comment.user == user || (can? :manage, comment.commentable)
    end
    can :create, Like do |like|
      user.persisted?
    end
    can :destroy, Like do |like|
      user.persisted? && like.voter_id == user.id
    end
    can :manage, Group do |group|
      user.is_admin_of? group
    end
    can :create, Group do |group|
      user.persisted?
    end
  end

  private
  def is_project_manager? project, user
    if project.owner_type == Group.name
      is_admin_of = user.is_admin_of? project.owner
    end   
    is_admin_of || user.is_owner_of?(project) || user.is_collaborator_of?(project)
  end

  def is_project_editor? project, user
    if project.owner_type == Group.name
      is_member_of = user.is_member_of? project.owner
    end   
    is_member_of || user.is_owner_of?(project) || user.is_collaborator_of?(project)
  end


end
