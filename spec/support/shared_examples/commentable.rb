shared_examples 'Commentable' do |*factory_args|
  describe '#comments' do
    let(:commentable) { FactoryGirl.create(*factory_args) }
    let(:comment) { FactoryGirl.create(:comment, commentable: commentable) }
    it do
      expect(commentable).to be_respond_to(:comments)
    end

    it do
      expect(commentable.comments).to be_member(comment)
    end
  end
end
