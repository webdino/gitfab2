class Ability
  include CanCan::Ability

  # TODO: This initialize function is too long to read,
  #   so it should be divided to multiple functions.
  def initialize(user)
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
      user.is_contributor_of?(annotation) || can?(:manage, annotation.state)
    end
    can :manage, Card::State do |card|
      can? :manage, card.project
    end
    can :manage, Card::NoteCard do |card|
      card.project && is_project_editor?(card.project, user)
    end
    can :read, Card::State do |card|
      can? :read, card.project
    end
    can :read, Card::NoteCard do |card|
      can? :read, card.project
    end
    # TODO: Project#manageable_by? に同様のロジックを移動、将来的にこれは削除予定
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
    can :manage, Attachment do |attachment|
      can? :update, attachment.attachable
    end
    can :manage, Collaboration do |collabo|
      can? :manage, collabo.project
    end
    can :destroy, CardComment do |comment|
      comment.user_id == user.id || (can? :manage, comment.card)
    end
    can :manage, Group do |group|
      !group.is_deleted && user.is_admin_of?(group)
    end
    can :create, Group do
      user.persisted?
    end
    can :create, Tag do |_tag|
      user.persisted?
    end
    can :destroy, Tag do |_tag|
      user.persisted?
    end
  end

  private

  # TODO: User#is_project_manager? に同様のロジックを移動、将来的にこれは削除予定
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
