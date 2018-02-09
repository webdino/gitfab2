# frozen_string_literal: true

shared_examples 'Contributable' do |*factory_args|
  describe '#contributions' do
    let(:contributable) { FactoryGirl.create(*factory_args) }
    let(:contribute) { FactoryGirl.create(:contribution, contributable: contributable) }
    it do
      expect(contributable).to be_respond_to(:contributions)
    end

    it do
      expect(contributable.contributions).to be_member(contribute)
    end
  end
end
