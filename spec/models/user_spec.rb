require "spec_helper"

describe User do
  disconnect_sunspot

  it_behaves_like 'Liker', :user
  it_behaves_like 'Collaborator', :user

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

  describe '#liked_projects' do
    let!(:project_a) { FactoryGirl.create :project }
    let!(:project_b) { FactoryGirl.create :project }
    let!(:project_not_like) { FactoryGirl.create :project }
    let!(:comment_a) { FactoryGirl.create :comment, commentable: project_not_like }
    before do
      FactoryGirl.create :like, liker_id: user.slug, likable: project_a
      FactoryGirl.create :like, liker_id: user.slug, likable: project_b
      FactoryGirl.create :like, liker_id: user.slug, likable: comment_a
    end

    it do
      expect(user.liked_projects.to_a).to contain_exactly(project_a, project_b)
    end
  end

  describe '#is_system_admin?' do
    it do
      expect(FactoryGirl.create(:user).is_system_admin?).to be_falsey
    end
    it do
      expect(FactoryGirl.create(:administrator).is_system_admin?).to be_truthy
    end
  end

  describe '#is_owner_of?(project)' do
    let!(:project_owned) { FactoryGirl.create :project, owner: user }
    let!(:project_not_owned) { FactoryGirl.create :project }
    it { expect(user.is_owner_of?(project_owned)).to be_truthy }
    it { expect(user.is_owner_of?(project_not_owned)).to be_falsey }
  end

  describe '#is_contributor_of?(project)' do
    let!(:project_contributed) { FactoryGirl.create :project, owner: user }
    let!(:project_not_contributed) { FactoryGirl.create :project }
    before { FactoryGirl.create(:contribution, contributor: user, contributable: project_contributed) }
    it { expect(user.is_contributor_of?(project_contributed)).to be_truthy }
    it { expect(user.is_contributor_of?(project_not_contributed)).to be_falsey }
  end

  describe '#is_admin_of?(group)' do
    let!(:group_administered) { FactoryGirl.create :group }
    let!(:group_membered) { FactoryGirl.create :group }
    let!(:group_not_membered) { FactoryGirl.create :group }
    before do
      FactoryGirl.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin])
      FactoryGirl.create(:membership, group: group_membered, user: user, role: Membership::ROLE[:editor])
    end
    it { expect(user.is_admin_of?(group_administered)).to be_truthy }
    it { expect(user.is_admin_of?(group_membered)).to be_falsey } # Maybe bugged
    it { expect(user.is_admin_of?(group_not_membered)).to be_falsey }
    it { expect(user.is_admin_of?(nil)).to be_falsey }
  end

  describe '#is_editor_of?(group)' do
    let!(:group_administered) { FactoryGirl.create :group }
    let!(:group_membered) { FactoryGirl.create :group }
    let!(:group_not_membered) { FactoryGirl.create :group }
    before do
      FactoryGirl.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin])
      FactoryGirl.create(:membership, group: group_membered, user: user, role: Membership::ROLE[:editor])
    end
    it { expect(user.is_editor_of?(group_administered)).to be_falsey } # Maybe bugged
    it { expect(user.is_editor_of?(group_membered)).to be_truthy }
    it { expect(user.is_editor_of?(group_not_membered)).to be_falsey }
    it { expect(user.is_editor_of?(nil)).to be_falsey }
  end

  describe '#membership_in(group)' do
    let!(:group_administered) { FactoryGirl.create :group }
    let!(:group_membered) { FactoryGirl.create :group }
    let!(:group_not_membered) { FactoryGirl.create :group }
    let!(:administered_membership) do
      FactoryGirl.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin])
    end
    let!(:membered_membership) do
      FactoryGirl.create(:membership, group: group_membered, user: user, role: Membership::ROLE[:editor])
    end
    it { expect(user.membership_in(group_administered)).to eq(administered_membership) }
    it { expect(user.membership_in(group_membered)).to eq(membered_membership) }
    it { expect(user.membership_in(group_not_membered)).to be_nil }
  end

  describe '#groups' do
    let!(:group_administered) { FactoryGirl.create :group }
    let!(:group_membered) { FactoryGirl.create :group }
    let!(:group_not_membered) { FactoryGirl.create :group }
    it do
      FactoryGirl.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin])
      FactoryGirl.create(:membership, group: group_membered, user: user, role: Membership::ROLE[:editor])
      expect(user.groups).to contain_exactly(group_administered, group_membered)
    end
    it { expect(user.groups).to be_empty }
  end

  describe '#join_to(group)' do
    let!(:group_membered) { FactoryGirl.create :group }
    let!(:group_not_membered) { FactoryGirl.create :group }
    subject { user.join_to(group_membered) }
    it { expect(subject).to be_an_instance_of(Membership) }
    it { expect{ subject }.to change{ user.membership_in(group_membered) } }
    it { expect{ subject }.to_not change{ user.membership_in(group_not_membered) } }
  end

  describe '#is_in_collaborated_group?(project)' do
    let!(:project_collaborated_by_user) { FactoryGirl.create :project }
    let!(:project_collaborated_by_group) { FactoryGirl.create :project }
    let!(:project_not_collaborated) { FactoryGirl.create :project }
    before do
      group = FactoryGirl.create(:group)
      user.join_to(group)
      user.collaborate!(project_collaborated_by_user)
      group.collaborate!(project_collaborated_by_group)
    end
    it { expect(user.is_in_collaborated_group?(project_collaborated_by_user)).to be_falsey }
    it { expect(user.is_in_collaborated_group?(project_collaborated_by_group)).to be_truthy }
    it { expect(user.is_in_collaborated_group?(project_not_collaborated)).to be_falsey }
  end

end
