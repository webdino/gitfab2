class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new
    can :manage, User, id: user.id
    can :manage, Tool
    can :manage, Way
    can :manage, Membership, Membership do |membership|
      user.is_admin_of?(membership.group) && user != membership.user
    end
    can :manage, Usage do
      user.persisted?
    end
    can :manage, Recipe do |recipe|
      user.can_manage? recipe
    end
    can :manage, Status do |status|
      user.can_manage? status.recipe
    end
    can :manage, Material do |material|
      user.can_manage? material.recipe
    end
    can :manage, Post do |post|
      user.can_manage? post.recipe
    end
    can :manage, PostAttachment do |pa|
      user.can_manage? pa.recipe
    end
    can :manage, Collaboration do |collabo|
      user.can_manage? collabo.recipe
    end
    can :create, Comment do
      user.persisted?
    end
    can [:update, :destroy], Comment do |comment|
      comment.user == user || (can? :manage, comment.commentable)
    end
    can :read, :all
  end
end
