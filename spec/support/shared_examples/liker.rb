# frozen_string_literal: true

shared_examples 'Liker' do |*factory_name|
  describe '#liked?(likable)' do
    let(:liker) { FactoryGirl.create(*factory_name) }
    let(:likable) { FactoryGirl.create(:user_project) }
    context 'likableをLikeしているとき' do
      before do
        FactoryGirl.create(:like, liker: liker, likable: likable)
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
