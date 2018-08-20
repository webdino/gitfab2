# frozen_string_literal: true

describe ProjectComment do
  describe "#manageable_by?" do
    subject { project_comment.manageable_by?(user) }
    let(:project_comment) { FactoryBot.create(:project_comment) }

    context "when user is a commenter" do
      let(:user) { project_comment.user }
      it { is_expected.to be true }
    end

    context "when user is not a commenter" do
      let(:user) { FactoryBot.create(:user) }

      context "and user is a project manager" do
        it do
          expect(project_comment.project).to receive(:manageable_by?).with(user).and_return(true)
          is_expected.to be true
        end
      end

      context "and user is a project manager" do
        it do
          expect(project_comment.project).to receive(:manageable_by?).with(user).and_return(false)
          is_expected.to be false
        end
      end
    end
  end
end
