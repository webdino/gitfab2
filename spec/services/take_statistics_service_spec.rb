describe TakeStatisticsService do
  describe '.call' do
    before do
      FactoryBot.create_list(:project_access_log, 5, project: project, created_at: yesterday)
      FactoryBot.create_list(:project_access_log, 10, project: FactoryBot.create(:project), created_at: yesterday)
      FactoryBot.create(:project_access_log, project: project, created_at: today)
      FactoryBot.create(:project_access_log, project: FactoryBot.create(:project), created_at: today)
      FactoryBot.create(:project)
    end

    let(:today) { Time.current }
    let(:yesterday) { today.yesterday }
    let(:project) { FactoryBot.create(:project) }

    it do
      expect { TakeStatisticsService.call(yesterday.to_date) }.to change(ProjectAccessStatistic, :count).by(2)
    end

    describe 'ProjectAccessStatistic' do
      before { TakeStatisticsService.call(yesterday.to_date) }
      subject(:project_access_statistic) { ProjectAccessStatistic.find_by(project: project) }

      it do
        expect(project_access_statistic).to be_an_instance_of(ProjectAccessStatistic)
      end

      it do
        expect(project_access_statistic.date_on).to eq yesterday.to_date
      end

      it do
        expect(project_access_statistic.access_count).to eq 5
      end
    end
  end
end
