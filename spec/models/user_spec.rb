# frozen_string_literal: true

describe User do
  it_behaves_like 'Collaborator', :user
  it_behaves_like 'ProjectOwner', :user
  it_behaves_like 'DraftInterfaceTest', FactoryBot.create(:user)
  it_behaves_like 'Sign up Interface', User.new

  let(:user) { FactoryBot.create :user }
  let(:project) { FactoryBot.create :user_project }
  let(:group) { FactoryBot.create :group }

  describe 'validations' do
    let(:user) { FactoryBot.create(:user, email: email , email_confirmation: email) }
    let(:email) { 'foo@example.com' }

    describe '#confirm_email' do
      subject { user.valid? }

      context 'when email_confirmation is blank' do
        before { user.email_confirmation = email_confirmation }
        let(:email_confirmation) { '' }

        context 'on email unchanged' do
          it { is_expected.to be true }
        end

        context 'on email changed' do
          context 'when email_confirmation matches email (email is blank)' do
            before { user.email = email_confirmation }
            it { is_expected.to be false }
          end

          context 'when email_confirmation does not match email' do
            before { user.email = 'not_match@example.com' }
            it { is_expected.to be false }
          end
        end
      end

      context 'when email_confirmation is present' do
        before { user.email_confirmation = email }

        context 'on email unchanged' do
          it { is_expected.to be true }
        end

        context 'on email changed' do
          before { user.email = new_email }
          let(:new_email) { 'new_email@example.com' }

          context 'when email_confirmation matches email' do
            before { user.email_confirmation = new_email }
            it { is_expected.to be true }
          end

          context 'when email_confirmation does not match email' do
            before { user.email_confirmation = 'not_match@example.com' }
            it { is_expected.to be false }
          end
        end
      end
    end
  end

  describe '.create_from_identity' do
    subject { User.create_from_identity(identity, attributes) }
    let(:identity) { FactoryBot.create(:identity, user: nil) }

    context 'with valid attributes' do
      let(:attributes) { FactoryBot.attributes_for(:user) }
      it { is_expected.to be_kind_of User }
      it do
        expect{ subject }.to change{ User.count }.by(1)
                        .and change{ identity.user }
      end
    end

    context 'with invalid attributes' do
      let(:attributes) { FactoryBot.attributes_for(:user, name: nil) }
      it { is_expected.to be_kind_of User }
      it { expect{ subject }.not_to change{ User.count } }
      it { expect{ subject }.not_to change{ identity.reload.user } }
    end
  end

  # #623 local test could pass, but travis was failed.
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
    it { expect(user.is_owner_of?(project_owned)).to be true }
    it { expect(user.is_owner_of?(project_not_owned)).to be false }
  end

  describe '#is_contributor_of?' do
    let!(:contributed_card) { FactoryBot.create(:card) }
    let!(:not_contributed_card) { FactoryBot.create(:card) }
    before { FactoryBot.create(:contribution, contributor: user, card: contributed_card) }
    it { expect(user.is_contributor_of?(contributed_card)).to be true }
    it { expect(user.is_contributor_of?(not_contributed_card)).to be false }
  end

  describe '#is_admin_of?' do
    let!(:group_administered) { FactoryBot.create :group }
    let!(:group_not_membered) { FactoryBot.create :group }
    before { FactoryBot.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin]) }
    it { expect(user.is_admin_of?(group_administered)).to be true }
    it { expect(user.is_admin_of?(group_not_membered)).to be false }
    it { expect(user.is_admin_of?(nil)).to be false }
  end

  describe '#is_editor_of?' do
    let!(:group_administered) { FactoryBot.create :group }
    let!(:group_not_membered) { FactoryBot.create :group }
    before { FactoryBot.create(:membership, group: group_administered, user: user, role: Membership::ROLE[:admin]) }
    it { expect(user.is_editor_of?(group_administered)).to be false }
    it { expect(user.is_editor_of?(group_not_membered)).to be false }
    it { expect(user.is_editor_of?(nil)).to be false }
  end

  describe '#password_auth?' do
    let(:user) { User.new }
    it { expect(user.password_auth?).to be false }
  end

  describe '#is_project_manager?' do
    subject { user.is_project_manager?(project) }

    context 'When the user is admin of the project' do
      let(:project) { FactoryBot.create(:group_project) }
      before { allow(user).to receive(:is_admin_of?).and_return(true) }
      it { is_expected.to be true }
    end

    context 'When the user is owner of the project' do
      before { allow(user).to receive(:is_owner_of?).and_return(true) }
      it { is_expected.to be true }
    end

    context 'When the user is collaborator of the project' do
      before { allow(user).to receive(:is_collaborator_of?).and_return(true) }
      it { is_expected.to be true }
    end

    context 'When the user is NOT admin of the project' do
      let(:project) { FactoryBot.create(:group_project) }
      before { allow(user).to receive(:is_admin_of?).and_return(false) }
      it { is_expected.to be false }
    end

    context 'When the user is NOT owner of the project' do
      before { allow(user).to receive(:is_owner_of?).and_return(false) }
      it { is_expected.to be false }
    end

    context 'When the user is NOT collaborator of the project' do
      before { allow(user).to receive(:is_collaborator_of?).and_return(false) }
      it { is_expected.to be false }
    end
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
        expect(user.is_admin_of?(group_membered)).to be false
        expect(user.is_editor_of?(group_membered)).to be true
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
    it { expect(user.is_in_collaborated_group?(project_collaborated_by_user)).to be false }
    it { expect(user.is_in_collaborated_group?(project_collaborated_by_group)).to be true }
    it { expect(user.is_in_collaborated_group?(project_not_collaborated)).to be false }
  end

  describe '#connected_with_github?' do
    subject { user.connected_with_github? }
    let(:user) { FactoryBot.create(:user) }

    context 'when user has GitHub identity' do
      before { FactoryBot.create(:identity, provider: 'github', user: user) }
      it { is_expected.to be true }
    end

    context 'when user does not have GitHub identity' do
      it { is_expected.to be false }
    end
  end

  describe '#connected_with_google?' do
    subject { user.connected_with_google? }
    let(:user) { FactoryBot.create(:user) }

    context 'when user has Google identity' do
      before { FactoryBot.create(:identity, provider: 'google_oauth2', user: user) }
      it { is_expected.to be true }
    end

    context 'when user does not have Google identity' do
      it { is_expected.to be false }
    end
  end

  describe '#connected_with_facebook?' do
    subject { user.connected_with_facebook? }
    let(:user) { FactoryBot.create(:user) }

    context 'when user has Facebook identity' do
      before { FactoryBot.create(:identity, provider: 'facebook', user: user) }
      it { is_expected.to be true }
    end

    context 'when user does not have Facebook identity' do
      it { is_expected.to be false }
    end
  end

  describe '#resign!' do
    subject { user.resign! }

    let(:identity) { FactoryBot.create(:identity, user: nil) }
    let(:attributes) do
      {
        authority: 'admin',
        avatar: fixture_file_upload('images/image.jpg'),
        email: 'sample@example.com',
        email_confirmation: 'sample@example.com',
        is_deleted: false,
        location: 'Japan',
        name: 'sample-user',
        password_digest: 'password_digest',
        url: 'example.com'
      }
    end

    let(:user) { User.create_from_identity(identity, attributes) }

    it 'updates a user with dummy' do
      subject
      expect(user).to have_attributes(
        authority: nil,
        email: "#{user.name}@fabble.cc",
        email_confirmation: "#{user.name}@fabble.cc",
        is_deleted: true,
        location: nil,
        password_digest: nil,
        url: nil
      )
      expect(user.name).to start_with('deleted-user-')
    end

    it 'deletes user avatar' do
      subject
      expect(user.avatar.file).to be_nil
    end

    it 'deletes user identities' do
      subject
      expect(user.identities).to be_empty
    end

    it 'deletes user projects' do
      expect(user.projects).to receive(:soft_destroy_all!).once
      subject
    end

    it 'deletes user memberships' do
      FactoryBot.create_list(:membership, 2, user: user)
      subject
      expect(user.memberships).to be_empty
    end

    describe 'likes' do
      let!(:project) { FactoryBot.create(:project) }
      before { FactoryBot.create(:like, user: user, project: project) }

      it 'deletes user likes' do
        subject
        expect(user.likes).to be_empty
      end

      it 'decrements project likes_count' do
        expect{ subject }.to change{ project.reload.likes_count }.by(-1)
      end
    end

    describe 'card_comments' do
      let!(:card_comment) { FactoryBot.create_list(:card_comment, 2, user: user) }

      it 'updates user card_comments' do
        subject
        expect(user.card_comments).to be_all { |comment| comment.body == '（このユーザーは退会しました）' }
      end
    end

    describe 'project_comments' do
      let!(:project_comment) { FactoryBot.create_list(:project_comment, 2, user: user) }

      it 'updates user project_comments' do
        subject
        expect(user.project_comments).to be_all { |comment| comment.body == '（このユーザーは退会しました）' }
      end
    end

    describe 'my_notifications' do
      let!(:my_notifications) { FactoryBot.create_list(:notification, 2, notified: user) }

      it 'deletes my_notifications' do
        subject
        expect(user.my_notifications).to be_empty
      end
    end

    describe 'notifications_given' do
      let!(:notifications_given) { FactoryBot.create_list(:notification, 2, notifier: user) }

      it 'deletes notifications_given' do
        subject
        expect(user.notifications_given).to be_empty
      end
    end

    describe 'collaborations' do
      let!(:collaborations) { FactoryBot.create_list(:collaboration, 2, owner: user) }

      it 'deletes collaborations' do
        subject
        expect(user.collaborations).to be_empty
      end
    end

    context 'when raise an error' do
      let!(:data) do
        [
          FactoryBot.create_list(:project, 2, owner: user),
          FactoryBot.create_list(:membership, 2, user: user),
          FactoryBot.create_list(:like, 2, user: user),
          FactoryBot.create_list(:card_comment, 2, user: user),
          FactoryBot.create_list(:project_comment, 2, user: user),
          FactoryBot.create_list(:notification, 2, notified: user),
          FactoryBot.create_list(:notification, 2, notifier: user),
        ]
      end

      before { allow(subject).to receive(:raise) }
      it { expect{ subject }.not_to change{ data } }
    end
  end

  describe '#active' do
    subject { User.active }
    let!(:active) { FactoryBot.create(:user, is_deleted: false) }
    let!(:deleted) { FactoryBot.create(:user, is_deleted: true) }

    it { is_expected.to eq [active] }
  end
end
