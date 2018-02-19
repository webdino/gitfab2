# frozen_string_literal: true

shared_examples 'Figurable' do |*factory_args|
  describe '#figures' do
    let(:figurable) { FactoryGirl.create(*factory_args) }
    let(:figure) { FactoryGirl.create(:figure, figurable: figurable) }

    it do
      expect(figurable).to be_respond_to(:figures)
    end

    it do
      expect(figurable.figures).to be_member(figure)
    end
  end
end
