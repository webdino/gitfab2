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

  describe "#fork_for!" do
    let(:forker){FactoryGirl.create :user}
    let(:derivative_project){project.fork_for! forker}
    before do
      project.recipe.recipe_cards.create _type: Card::State,
        title: "a state", description: "desc"
      project.recipe.recipe_cards.create _type: Card::Transition,
        title: "a transition", description: "desc"
      project.reload
    end
    it{expect(project.recipe).to have(2).recipe_cards}
    it{expect(derivative_project.owner).to eq forker}
    it{expect(derivative_project.recipe).to have(2).recipe_cards}
    it{expect(derivative_project.id).not_to eq project.id}
  end
end
