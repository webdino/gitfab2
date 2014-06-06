require "spec_helper"

describe User do
  disconnect_sunspot

  let(:user){FactoryGirl.create :user}
  let(:project){FactoryGirl.create :user_project}
  let(:group){FactoryGirl.create :group}

  describe "#groups" do
    let(:user_joining_groups){FactoryGirl.create_list :group, 3}
    before do
      user_joining_groups.each do |group|
        user.memberships.create group_id: group.id
      end
      user.reload
    end
    subject{user.groups}
    it{should eq user_joining_groups}
  end

  describe "#collaborate!" do
    before do
      user.collaborate! project
      user.reload
    end
    subject do
      collaboration = user.collaborations.find_by project: project
      collaboration.project
    end
    it{should eq project}
  end
  
  describe "#is_collaborator_of?" do
    before do
      user.collaborate! project
      user.reload
    end
    subject do
      collaboration = user.collaborations.find_by project: project
      collaboration.project
    end
    it{should eq project}
  end
end
