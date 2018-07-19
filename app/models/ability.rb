class Ability
  include CanCan::Ability

  # TODO: This initialize function is too long to read,
  #   so it should be divided to multiple fucntions.
  def initialize(user, params)
    user ||= User.new
    can :manage, User, id: user.id
    can :manage, Membership do |membership|
      user.is_admin_of?(membership.group) || user == membership.user
    end
    can :create, Card::Usage do |_card|
      user.persisted?
    end
    can :manage, Card::Usage do |card|
      card.project && (user.is_contributor_of?(card) || is_project_editor?(card.project, user))
    end
    can :create, Card::Annotation do |_card|
      user.persisted?
    end
    can :manage, Card::Annotation do |annotation|
      user.is_contributor_of?(annotation) || can?(:manage, annotation.card)
    end
    can :manage, Card::State do |card|
      card.recipe && is_project_editor?(card.recipe.project, user)
    end
    can :manage, Card::NoteCard do |card|
      card.project && is_project_editor?(card.project, user)
    end
    can :read, Card::State do |card|
      can? :read, card.recipe.project
    end
    can :read, Card::NoteCard do |card|
      can? :read, card.project
    end
    can :manage, Project do |project|
      !project.is_deleted && is_project_manager?(project, user)
    end
    can :update, Project do |project|
      if project.is_deleted
        false
      else
        is_project_manager?(project, user)
      end
    end
    can :edit, Project do |project|
      !project.is_deleted && is_project_editor?(project, user)
    end
    can :read, Project do |project|
      if project.is_deleted
        false
      else
        !project.is_private ? true : is_project_editor?(project, user)
      end
    end
    can :update, Recipe do |recipe|
      user.is_member_of? recipe.owner if recipe.owner_type == Group.name
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
    can :destroy, Comment do |comment|
      comment.user_id == user.slug || (can? :manage, comment.card)
    end
    can :create, Like do |_like|
      user.persisted?
    end
    can :destroy, Like do |like|
      user.persisted? && like.voter_id == user.id
    end
    can :manage, Group do |group|
      user.is_admin_of? group
    end
    can :create, Group do |_group|
      user.persisted?
    end
    can :create, Tag do |_tag|
      user.persisted?
    end
    can :destroy, Tag do |_tag|
      user.persisted?
    end
    can :manage, Notification do |notification|
      user == notification.notified || notification.notifier
    end
  end

  private

  def is_project_manager?(project, user)
    if project.owner_type == Group.name
      is_admin_of = user.is_admin_of? project.owner
    end
    is_admin_of || user.is_owner_of?(project) || user.is_collaborator_of?(project)
  end

  def is_project_editor?(project, user)
    if project.owner_type == Group.name
      is_member_of = user.is_member_of? project.owner
    end
    is_member_of ||
      user.is_owner_of?(project) ||
      user.is_collaborator_of?(project) ||
      user.is_in_collaborated_group?(project)
  end
end
