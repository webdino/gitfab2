require "spec_helper"
require "cancan/matchers"

describe "User ability" do
  let(:user){FactoryGirl.create :user}
  let(:recipe){user.recipes.create}
  subject(:ability){Ability.new user}
  context "when is the owner of the recipe" do
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
  context "when isn't the owner of the recipe" do
    let(:other){FactoryGirl.create :user}
    let(:recipe){other.recipes.create}
    let(:status){Status.create recipe: recipe}
    let(:way){Way.create status: status}
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
    describe "doesn't let user manage the tools of the recipe" do
      it{should_not be_able_to :manage, tool}
    end
    describe "lets user manage the ways of the recipe" do
      it{should be_able_to :manage, way}
    end
    describe "lets user read the recipe" do
      it{should be_able_to :read, recipe}
    end
  end
end
