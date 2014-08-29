require "spec_helper"

describe User do
  disconnect_sunspot

  let(:user){FactoryGirl.create :user}
  let(:project){FactoryGirl.create :user_project}
  let(:group){FactoryGirl.create :group}

  # #623 local test could pass, but travis was faild.
  #describe "#groups" do
  #  let(:user_joining_groups){FactoryGirl.create_list :group, 3}
  #  before do
  #    user_joining_groups.each do |group|
  #      user.memberships.create group_id: group.id
  #    end
  #    user.reload
  #  end
  #  subject{user.groups}
  #  it{should eq user_joining_groups}
  #end

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

  describe "#liked_projects" do
    before do
      user.projects.create! title: "title2", name: "title2"
      user.projects.create! title: "title3", name: "title3"
      project.likes.create liker: user.id
    end
    subject{user.liked_projects}
    it{should eq [project]}
  end
end
