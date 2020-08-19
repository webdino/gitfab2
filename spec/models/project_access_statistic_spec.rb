RSpec.describe ProjectAccessStatistic, type: :model do
  describe '.access_ranking' do
    example do
      yesterday = Date.yesterday
      last_month = (yesterday - 1.month).to_date

      project_a = FactoryBot.create(:project)
      project_b = FactoryBot.create(:project)
      project_c = FactoryBot.create(:project)

      # project_a 10 + 100 = 110
      # project_b 10 + 100 + 1000 = 1110
      FactoryBot.create(:project_access_statistic, date_on: yesterday, project: project_a, access_count: 10)
      FactoryBot.create(:project_access_statistic, date_on: last_month, project: project_a, access_count: 100)
      FactoryBot.create(:project_access_statistic, date_on: last_month - 1, project: project_a, access_count: 1000)
      FactoryBot.create(:project_access_statistic, date_on: yesterday, project: project_b, access_count: 10)
      FactoryBot.create(:project_access_statistic, date_on: last_month, project: project_b, access_count: 100)
      FactoryBot.create(:project_access_statistic, date_on: last_month + 1, project: project_b, access_count: 1000)
      FactoryBot.create(:project_access_statistic, date_on: last_month - 1, project: project_c, access_count: 10)

      expect(ProjectAccessStatistic.access_ranking(from: last_month, to: yesterday)).to eq [project_b, project_a]
    end
  end
end
