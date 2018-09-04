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

  describe '#deletable?' do
    subject { group.deletable? }
    let(:group) { FactoryBot.create :group }

    it { is_expected.to eq true }

    context 'when group has projects' do
      before { FactoryBot.create(:project, owner: group) }

      it { is_expected.to eq false }
    end

    context 'when projects are all deleted' do
      before { FactoryBot.create_list(:project, 2, owner: group, is_deleted: true) }

      it { is_expected.to eq true }
    end
  end

  describe '#soft_destroy!' do
    subject { group.soft_destroy! }
    let(:group) { FactoryBot.create(:group) }
    let(:collaborations) { FactoryBot.create_list(:collaboration, 2, owner: group) }

    it { expect { subject }.to change { group.is_deleted }.from(false).to(true) }
    it { expect { subject }.to change { group.collaborations.count }.by(0) }

    context 'when failing to update group' do
      before { allow(group).to receive(:update!).and_raise(ActiveRecord::RecordNotSaved) }

      it 'does NOT delete group' do
        expect do
          begin
            subject
          rescue ActiveRecord::RecordNotSaved => _
          end
        end.not_to change { group.is_deleted }
      end
    end

    context 'when failing to delete all collaborations' do
      before { allow(Collaboration).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed) }

      it 'does NOT delete collaborations' do
        expect do
          begin
            subject
          rescue ActiveRecord::RecordNotDestroyed => _
          end
        end.not_to change { group.collaborations.count }
      end
    end
  end
end
