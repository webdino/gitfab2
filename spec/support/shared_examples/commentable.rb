# frozen_string_literal: true

shared_examples 'Commentable' do |*factory_args|
  describe '#comments' do
    let(:commentable) { FactoryBot.create(*factory_args) }
    let(:comment) { FactoryBot.create(:comment, commentable: commentable) }
    it do
      expect(commentable).to be_respond_to(:comments)
    end

    it do
      expect(commentable.comments).to be_member(comment)
    end
  end
end
