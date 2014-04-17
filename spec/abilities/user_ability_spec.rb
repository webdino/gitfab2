require "spec_helper"
require "cancan/matchers"

describe "User ability" do
  disconnect_sunspot
  let(:user){FactoryGirl.create :user}
  let(:other){FactoryGirl.create :user}
  let(:recipe){FactoryGirl.create :recipe, user: user}

  subject(:ability){Ability.new user}
  context "when is the admin of the recipe" do
    describe "lets user manage own recipe" do
      it{should be_able_to :manage, recipe}
    end
    describe "lets user manage the statuses of the recipe" do
      it{should be_able_to :manage, Status, recipe_id: recipe.id}
    end
    describe "lets user manage the materials of the recipe" do
      it{should be_able_to :manage, Material, recipe_id: recipe.id}
    end
    describe "lets user manage the tools of the recipe" do
      it{should be_able_to :manage, Tool, recipe_id: recipe.id}
    end
    describe "lets user manage the ways of the recipe" do
      it{should be_able_to :manage, Way, recipe_id: recipe.id}
    end
  end
  context "when isn't the admin of the recipe" do
    let(:other){FactoryGirl.create :user}
    let(:recipe){FactoryGirl.create :recipe, user: other}
    let(:status){FactoryGirl.create :status, recipe: recipe}
    let(:way){FactoryGirl.create :way, status: status}
    let(:material){Material.create recipe: recipe}
    let(:tool){Tool.create recipe: recipe}
    describe "doesn't let user create other's recipe" do
      it{should_not be_able_to :manage, recipe}
    end
    describe "doesn't let user manage the statuses of the recipe" do
      it{should_not be_able_to :manage, status}
    end
    describe "doesn't let user manage the materials of the recipe" do
      it{should_not be_able_to :manage, material}
    end
    describe "lets user manage the tools of the recipe" do
      it{should be_able_to :manage, tool}
    end
    describe "lets user manage the ways of the recipe" do
      it{should be_able_to :manage, way}
    end
    describe "lets user read the recipe" do
      it{should be_able_to :read, recipe}
    end
  end
  context "when is an admin of a group" do
    let(:group){FactoryGirl.create :group, creator: user}
    before{group.add_admin other}
    describe "lets user manage the memberships of the group" do
      it{should be_able_to :manage, group.memberships.find_by(user_id: other.id)}
    end
    describe "doesn't let user manage his/her memberships of the group" do
      it{should_not be_able_to :manage, group.memberships.find_by(user_id: user.id)}
    end
  end
  context "when is an editor of a group" do
    let(:group){FactoryGirl.create :group, creator: other}
    before{group.add_editor user}
    describe "doesn't let user the memberships of the group" do
      it{should_not be_able_to :manage, group.memberships.find_by(user_id: other.id)}
    end
  end
  context "when isn't a member of a group" do
    let(:group){FactoryGirl.create :group, creator: other}
    describe "doesn't let user manage the memberships of the group" do
      it{should_not be_able_to :manage, group.memberships.find_by(user_id: other.id)}
    end
  end

  context "when is a collaborator of a group" do
    let(:other){FactoryGirl.create :user}
    subject(:ability){Ability.new other}
    describe "lets user manage the memberships of the group" do
      before{recipe.collaborators << other}
      it{should be_able_to :manage, recipe}
    end
    describe "doesn't let user manage his/her memberships of the group" do
      it{should_not be_able_to :manage, recipe}
    end
  end
end
