require 'spec_helper'

describe Comment do
  it_behaves_like 'Likable', :comment
  it_behaves_like 'Contributable', :comment

  describe 'attributes' do
    let(:comment) { FactoryGirl.create(:comment) }
    it { expect(comment).to be_respond_to(:body) }
  end

  describe "#user" do
    let(:comment) { FactoryGirl.create(:comment) }
    it { expect(comment).to be_respond_to(:user) }
    it { expect(comment.user).to be_an_instance_of(User) }
  end

  describe "#commentable" do
    let(:comment) { FactoryGirl.create(:comment) }
    it { expect(comment).to be_respond_to(:commentable) }
    it { expect(comment.commentable.class).to be_include(Commentable) }
  end

end
