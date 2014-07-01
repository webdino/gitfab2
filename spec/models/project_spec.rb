require "spec_helper"

describe Project do
  disconnect_sunspot

  let(:project){FactoryGirl.create :user_project}
  let(:user1){FactoryGirl.create :user}
  let(:user2){FactoryGirl.create :user}

  describe "#collaborators" do
    before do
      user1.collaborations.create project_id: project
      user2.collaborations.create project_id: project
    end
    subject{project.collaborators}
    it{should eq [user1, user2]}
  end

  describe "#fork_for" do
    let(:derivative_project){project.fork_for user1}
    before do
      project.recipe.recipe_cards.create _type: Card::State,
        title: "a state", description: "desc"
      project.recipe.recipe_cards.create _type: Card::Transition,
        title: "a transition", description: "desc"
    end
    it{expect(derivative_project.recipe).to have(2).recipe_cards}
  end
end
