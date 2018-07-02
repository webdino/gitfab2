# frozen_string_literal: true

shared_examples 'Liker' do |*factory_name|
  describe '#liked?(likable)' do
    let(:liker) { FactoryBot.create(*factory_name) }
    let(:likable) { FactoryBot.create(:user_project) }
    context 'likableをLikeしているとき' do
      before do
        FactoryBot.create(:like, liker: liker, likable: likable)
      end
      it 'returns true' do
        expect(liker.liked?(likable)).to be_truthy
      end
    end
    context 'likableをLikeしていないとき' do
      it 'returns false' do
        expect(liker.liked?(likable)).to be_falsey
      end
    end
  end
end
