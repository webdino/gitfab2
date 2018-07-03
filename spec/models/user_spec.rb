# frozen_string_literal: true

describe User do
  it_behaves_like 'Liker', :user
  it_behaves_like 'Collaborator', :user
  it_behaves_like 'ProjectOwner', :user

  let(:user) { FactoryBot.create :user }
  let(:project) { FactoryBot.create :user_project }
  let(:group) { FactoryBot.create :group }

  # #623 local test could pass, but travis was faild.
  # describe "#groups" do
  #  let(:user_joining_groups){FactoryBot.create_list :group, 3}
  #  before do
  #    user_joining_groups.each do |group|
  #      user.memberships.create group_id: group.id
  #    end
  #    user.reload
  #  end
  #  subject{user.groups}
  #  it{ is_expected.to eq user_joining_groups}
  # end

  describe '#collaborate!' do
    before do
      user.collaborate! project
      user.reload
    end
    subject do
      collaboration = user.collaborations.find_by project: project
      collaboration.project
    end
    it { is_expected.to eq project }
  end

  describe '#is_collaborator_of?' do
    before do
      user.collaborate! project
      user.reload
    end
    subject do
      collaboration = user.collaborations.find_by project: project
      collaboration.project
    end
    it { is_expected.to eq project }
  end

  describe '#liked_projects' do
    let!(:project_a) { FactoryBot.create :project, owner: user }
    let!(:project_b) { FactoryBot.create :project, owner: user }
    let!(:project_not_like) { FactoryBot.create :project, owner: user }
    let!(:comment_a) { FactoryBot.create :comment, commentable: project_not_like }
    before do
      FactoryBot.create :like, liker_id: user.id, likable: project_a
      FactoryBot.create :like, liker_id: user.id, likable: project_b
      FactoryBot.create :like, liker_id: user.id, likable: comment_a
    end

    it do
      expect(user.liked_projects.to_a).to contain_exactly(project_a, project_b)
    end
  end

  describe '#is_system_admin?' do
    subject { user.is_system_admin? }
    let(:user) { User.new(authority: authority) }

    context "when user has admin authority" do
      let(:authority) { "admin" }
      it { is_expected.to be true }
    end

    context "when user does not have admin authority" do
      let(:authority) { nil }
      it { is_expected.to be false }
    end
  end

  describe '#is_owner_of?(project)' do
    let(:someone_else) { FactoryBot.create :user }
    let!(:project_owned) { FactoryBot.create :project, owner: user }
    let!(:project_not_owned) { FactoryBot.create :project, owner: someone_else }
    it { expect(user.is_owner_of?(project_owned)).to be_truthy }
    it { expect(user.is_owner_of?(project_not_owned)).to be_falsey }
  end

  describe '#is_contributor_of?(project)' do
    let!(:project_contributed) { FactoryBot.create :project, owner: user }
    let!(:project_not_contributed) { FactoryBot.create :project, owner: user }
    before { FactoryBot.create(:contribution, contributor: user, contributable: project_contributed) }
    it { expect(user.is_contributor_of?(project_contributed)).to be_truthy }
    it { expect(user.is_contributor_of?(project_not_contributed)).to be_falsey }
  end

  describe '#is_admin_of?(group)' do
    let!(:group_administered) { FactoryBot.create :group }
    let!(:group_not_membered) { FactoryBot.create :group }
    before { FactoryBot.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin]) }
    it { expect(user.is_admin_of?(group_administered)).to be_truthy }
    it { expect(user.is_admin_of?(group_not_membered)).to be_falsey }
    it { expect(user.is_admin_of?(nil)).to be_falsey }
  end

  describe '#is_editor_of?(group)' do
    let!(:group_administered) { FactoryBot.create :group }
    let!(:group_not_membered) { FactoryBot.create :group }
    before { FactoryBot.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin]) }
    it { expect(user.is_editor_of?(group_administered)).to be_falsey }
    it { expect(user.is_editor_of?(group_not_membered)).to be_falsey }
    it { expect(user.is_editor_of?(nil)).to be_falsey }
  end

  describe 'ユーザーをeditorとしてグループに追加するとき' do
    let!(:group_membered) { FactoryBot.create :group }

    context 'グループにadminがすでに存在している場合' do
      before do
        # 先にadminとなるユーザーとgroup_memberedを紐づけておく
        admin = FactoryBot.create(:user)
        FactoryBot.create(:membership, group: group_membered, user: admin, role: Membership::ROLE[:admin])
        # ２番目のユーザーはrole: 'editor'となる（すでにadminがグループにいるので）
        FactoryBot.create(:membership, group: group_membered, user: user, role: Membership::ROLE[:editor])
      end
      it "role: 'editor'として登録されること" do
        expect(user.is_admin_of?(group_membered)).to be_falsey
        expect(user.is_editor_of?(group_membered)).to be_truthy
      end
    end

    context 'グループにadminが存在していない場合' do
      before { FactoryBot.create(:membership, group: group_membered, user: user, role: Membership::ROLE[:editor]) }
      it "role: 'admin'として登録されること" do
        expect(user.is_admin_of?(group_membered)).to be_truthy
        expect(user.is_editor_of?(group_membered)).to be_falsey
      end
    end
  end

  describe '#membership_in(group)' do
    let!(:group_administered) { FactoryBot.create :group }
    let!(:group_membered) { FactoryBot.create :group }
    let!(:group_not_membered) { FactoryBot.create :group }
    let!(:administered_membership) do
      FactoryBot.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin])
    end
    let!(:membered_membership) do
      FactoryBot.create(:membership, group: group_membered, user: user, role: Membership::ROLE[:editor])
    end
    it { expect(user.membership_in(group_administered)).to eq(administered_membership) }
    it { expect(user.membership_in(group_membered)).to eq(membered_membership) }
    it { expect(user.membership_in(group_not_membered)).to be_nil }
  end

  describe '#groups' do
    let!(:group_administered) { FactoryBot.create :group }
    let!(:group_membered) { FactoryBot.create :group }
    let!(:group_not_membered) { FactoryBot.create :group }
    it do
      FactoryBot.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin])
      FactoryBot.create(:membership, group: group_membered, user: user, role: Membership::ROLE[:editor])
      expect(user.groups).to contain_exactly(group_administered, group_membered)
    end
    it { expect(user.groups).to be_empty }
  end

  describe '#join_to(group)' do
    let!(:group_membered) { FactoryBot.create :group }
    let!(:group_not_membered) { FactoryBot.create :group }
    subject { user.join_to(group_membered) }
    it { expect(subject).to be_an_instance_of(Membership) }
    it { expect { subject }.to change { user.membership_in(group_membered) } }
    it { expect { subject }.to_not change { user.membership_in(group_not_membered) } }
  end

  describe '#is_in_collaborated_group?(project)' do
    let(:someone_else) { FactoryBot.create :user }
    let!(:project_collaborated_by_user) { FactoryBot.create :project, owner: someone_else }
    let!(:project_collaborated_by_group) { FactoryBot.create :project, owner: someone_else }
    let!(:project_not_collaborated) { FactoryBot.create :project, owner: someone_else }
    # 他のユーザーが作成したプロジェクトやグループとコラボレートする
    before do
      group = FactoryBot.create(:group)
      user.join_to(group)
      user.collaborate!(project_collaborated_by_user)
      group.collaborate!(project_collaborated_by_group)
    end
    it { expect(user.is_in_collaborated_group?(project_collaborated_by_user)).to be_falsey }
    it { expect(user.is_in_collaborated_group?(project_collaborated_by_group)).to be_truthy }
    it { expect(user.is_in_collaborated_group?(project_not_collaborated)).to be_falsey }
  end

  describe '#generate_draft' do
    user = FactoryBot.create(:user)
    it_behaves_like 'DraftGenerator', user
  end
end
