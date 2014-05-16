class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new
    can :manage, User, id: user.id
    can :manage, Tool
    can :manage, Membership do |membership|
      user.is_admin_of?(membership.group) || user == membership.user
    end
    can :manage, Usage do
      user.persisted?
    end
    can :manage, Recipe do |recipe|
      if recipe.owner_type == Group.name
        is_admin = user.is_admin_of? recipe.owner
      end
      user.is_owner_of?(recipe) ||
        user.is_collaborator_of?(recipe) ||
        is_admin
    end
    can :update, Recipe do |recipe|
      if recipe.owner_type == Group.name
        user.is_member_of? recipe.owner
      end
    end
    can :manage, Status do |status|
      can? :update, status.recipe
    end
    can :manage, Way do |way|
      can?(:update, way.recipe) || user.is_creator_of?(way)
    end
    can [:create, :update], Way do
      user.persisted?
    end
    can :manage, Material do |material|
      can? :update, material.recipe
    end
    can :manage, Post do |post|
      can? :update, post.recipe
    end
    can :manage, Attachment do |pa|
      can? :update, pa.recipe
    end
    can :manage, Collaboration do |collabo|
      can? :manage, collabo.recipe
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
    can :read, :all
  end
end
