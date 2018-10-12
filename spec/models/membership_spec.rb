# frozen_string_literal: true

describe Membership do
  describe '#admin?' do
    subject { membership.admin? }
    let(:membership) { FactoryBot.create(:membership, role: 'admin') }
    it { is_expected.to be true }
  end

  describe '#editor?' do
    subject { membership.editor? }
    let(:group) { FactoryBot.create(:group) }
    let(:membership) { FactoryBot.create(:membership, role: 'editor', group: group) }
    # 最低でも１人はadminが必要なので作成
    before { FactoryBot.create(:membership, role: 'admin', group: group) }
    it { is_expected.to eq true }
  end

  describe '#deletable?' do
    subject { membership.deletable? }

    context 'when 1 admin' do
      let(:membership) { FactoryBot.create(:membership, role: 'admin') }
      it { is_expected.to eq false }
    end

    context 'when 2 admins' do
      let(:memberships) { FactoryBot.create_list(:membership, 2, role: 'admin', group: FactoryBot.create(:group)) }
      let(:membership) { memberships.first }
      it { is_expected.to eq true }
    end

    context 'when role is editor' do
      let(:group) { FactoryBot.create(:group) }
      let(:membership) { FactoryBot.create(:membership, role: 'editor', group: group) }

      before { FactoryBot.create(:membership, role: 'admin', group: group) }
      it { is_expected.to eq true }
    end
  end

  describe 'after_destroy' do
    let(:group) { FactoryBot.create(:group) }
    let(:membership) { FactoryBot.create(:membership, group: group) }

    context 'when group has no other members' do
      it do
        expect(group).to receive(:soft_destroy!)
        membership.destroy
      end
    end

    context 'when group has other members' do
      before { FactoryBot.create(:membership, group: group) }
      it do
        expect(group).not_to receive(:soft_destroy!)
        membership.destroy
      end
    end
  end
end
