RSpec.describe ProjectAccessLog, type: :model do
  describe "#log!" do
    subject { ProjectAccessLog.log!(project, user) }

    let(:project) { FactoryBot.create(:user_project) }

    context "when anonymous user" do
      let(:user) { nil }
      it { expect{ subject }.to change(ProjectAccessLog, :count).by(1) }
    end

    context "when logged in user" do
      context "when current_user is a project manager" do
        let(:user) { project.owner }
        it { expect{ subject }.not_to change(ProjectAccessLog, :count) }
      end

      context "when current_user is not a project manager" do
        let(:user) { FactoryBot.create(:user) }
        it { expect{ subject }.to change(ProjectAccessLog, :count).by(1) }
      end
    end
  end
end
