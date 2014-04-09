class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new
    can :manage, User, id: user.id
    can :manage, Recipe do |recipe|
      user.is_owner_of?(recipe) || user.is_member_of?(recipe.group)
    end
    can :manage, Status do |status|
      recipe = status.recipe
      user.is_owner_of?(recipe) || user.is_member_of?(recipe.group)
    end
    can :manage, Material do |material|
      recipe = material.recipe
      user.is_owner_of?(recipe) || user.is_member_of?(recipe.group)
    end
    can :manage, Tool
    can :manage, Way
    can :manage, Membership, Membership do |membership|
      user.is_admin_of?(membership.group) && user != membership.user
    end
    can :manage, Usage do
      user.persisted?
    end
    can :manage, Post do |post|
      user.is_owner_of?(post.recipe) || user.is_member_of?(post.recipe.group)
    end
    can :manage, PostAttachment do |pa|
      user.is_owner_of?(pa.recipe) || user.is_member_of?(pa.recipe.group)
    end
    can :create, Tag
    can [:create, :destroy], RecipeTag
    can :read, :all
  end
end
