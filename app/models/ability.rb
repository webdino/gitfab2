class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new
    can :manage, User, id: user.id
    can :manage, Recipe, user_id: user.id
    can :manage, Recipe, Recipe do |recipe|
      user.groups.include? recipe.group
    end
    can :manage, Status, recipe: {user_id: user.id}
    can :manage, Material, recipe: {user_id: user.id}
    can :manage, Tool, recipe: {user_id: user.id}
    can :manage, Way
    can :read, :all
  end
end
