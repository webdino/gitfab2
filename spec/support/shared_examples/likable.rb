# frozen_string_literal: true

shared_examples 'Likable' do |*factory_name|
  describe '#likes' do
    let(:likable) { FactoryBot.create(*factory_name) }
    let(:like) { FactoryBot.create(:like, likable: likable) }
    it do
      expect(likable).to be_respond_to(:likes)
    end

    it do
      expect(likable.likes).to be_member(like)
    end
  end
end
