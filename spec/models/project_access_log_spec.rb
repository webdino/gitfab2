RSpec.describe ProjectAccessLog, type: :model do
  describe "#log!" do
    subject { ProjectAccessLog.log!(project, user) }

    let(:project) { FactoryBot.create(:user_project) }

    context "when anonymous user" do
      it "creates log each time" do
        expect{
          ProjectAccessLog.log!(project, nil)
          ProjectAccessLog.log!(project, nil) # revisit
        }.to change(ProjectAccessLog, :count).by(2)
      end
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
      subject { ProjectAccessLog.log!(revisit_project, user) }
      let(:revisit_project) { project }
      let(:user) { FactoryBot.create(:user) }

      before { ProjectAccessLog.log!(project, user) }

      context "on the same day" do
        context "on the same project" do
          it { expect{ subject }.not_to change(ProjectAccessLog, :count) }
        end

        context "on another project" do
          let(:revisit_project) { FactoryBot.create(:project) }
          it { expect{ subject }.to change(ProjectAccessLog, :count).by(1) }
        end
      end

      context "on the next day" do
        context "on the same project" do
          it "creates a new log" do
            travel 1.day
            expect { subject }.to change(ProjectAccessLog, :count).by(1)
          end

          specify "Each log creates on different days" do
            expect(ProjectAccessLog.first.created_at.today?).to eq true

            travel 1.day
            expect { subject }.to change(ProjectAccessLog, :count).by(1)
            expect(ProjectAccessLog.first.created_at.today?).to eq false
            expect(ProjectAccessLog.second.created_at.today?).to eq true
          end
        end

        context "on another project" do
          let(:revisit_project) { FactoryBot.create(:project) }
          it "creates a new log" do
            travel 1.day
            expect { subject }.to change(ProjectAccessLog, :count).by(1)
          end
        end
      end
    end
  end

  describe '.log_last_days!' do
    subject { ProjectAccessLog.log_last_days!(project, total, days: 30) }
    let(:project) { FactoryBot.create(:user_project) }

    context 'total < 30' do
      # total日分作成、1日あたり1つのログを作成
      let(:total) { 29 }

      it do
        expect{ subject }.to change{ ProjectAccessLog.count }.from(0).to(29)
      end

      specify '一番古いログが29日前に作成されていること' do
        subject
        oldest_log = ProjectAccessLog.first
        expect(oldest_log.created_at.to_date).to eq 29.days.ago.to_date
      end
    end

    context 'total == 30' do
      # 30日分作成、1日あたりtotalを30で割った数(四捨五入)でログを作成
      let(:total) { 30 }
      it 'creates 30 logs' do
        expect{ subject }.to change{ ProjectAccessLog.count }.from(0).to(30)
      end

      specify '一番古いログが30日前に作成されていること' do
        subject
        oldest_log = ProjectAccessLog.first
        expect(oldest_log.created_at.to_date).to eq 30.days.ago.to_date
      end
    end

    context 'total == 59' do
      # 30日分作成、1日あたりtotalを30で割った数(四捨五入)でログを作成
      let(:total) { 59 }
      it 'creates 60 logs' do
        expect{ subject }.to change{ ProjectAccessLog.count }.from(0).to(60)
      end

      specify '一番古いログが30日前に作成されていること' do
        subject
        oldest_log = ProjectAccessLog.first
        expect(oldest_log.created_at.to_date).to eq 30.days.ago.to_date
      end
    end
  end
end
