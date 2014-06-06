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
end
