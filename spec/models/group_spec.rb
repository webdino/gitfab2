# frozen_string_literal: true

describe Group do
  it_behaves_like 'Collaborator', :group
  it_behaves_like 'ProjectOwner', :user
  it_behaves_like 'DraftInterfaceTest', FactoryBot.create(:group)

  let(:user1) { FactoryBot.create :user }
  let(:user2) { FactoryBot.create :user }
  let(:group1) { FactoryBot.create :group }

  describe '#admins' do
    subject do
      group1.admins.map do |admin|
        group1.add_admin user2
        ms = admin.memberships.where(group_id: group1.id).first
        ms.admin?
      end.all?
    end
    it { is_expected.to be true }
  end

  describe '#editors' do
    subject do
      group1.editors.map do |editor|
        group1.add_editor user2
        ms = editor.memberships.where(group_id: group1.id).first
        ms.editor?
      end.all?
    end
    it { is_expected.to be true }
  end

  describe '#soft_destroy!' do
    subject { group.soft_destroy! }

    let!(:group) { FactoryBot.create(:group, name: name) }
    let(:name) { "group-name" }
    before { FactoryBot.create_list(:project, 2, owner: group, is_deleted: false) }

    it do
      expect { subject }.to change{ group.is_deleted }.from(false).to(true)
                       .and change{ group.name }.from(name).to(start_with("deleted-group-"))
    end
    it 'deletes all projects' do
      subject
      expect(group.projects).to be_all { |p| p.is_deleted? }
    end
  end

  describe '#active' do
    subject { Group.active }
    let!(:active) { FactoryBot.create(:group, is_deleted: false) }
    let!(:deleted) { FactoryBot.create(:group, is_deleted: true) }

    it { is_expected.to eq [active] }
  end
end
