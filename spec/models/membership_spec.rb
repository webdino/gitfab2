# frozen_string_literal: true

describe Membership do
  let(:membership) { FactoryBot.build :membership }
  describe '#admin?' do
    before { membership.role = Membership::ROLE[:admin] }
    subject { membership.admin? }
    it { is_expected.to be true }
  end
end
