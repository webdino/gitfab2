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

    describe "revisit" do
      subject { ProjectAccessLog.log!(project, nil, date) }

      before { ProjectAccessLog.log!(project, nil, created_on) }
      let(:created_on) { Date.current }

      context "on the same day" do
        let(:date) { created_on }
        it { expect{ subject }.not_to change(ProjectAccessLog, :count) }
      end

      context "on the next day" do
        let(:date) { created_on.next_day }
        it { expect{ subject }.to change(ProjectAccessLog, :count).by(1) }
      end
    end
  end
end
