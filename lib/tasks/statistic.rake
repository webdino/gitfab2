namespace :statistic do
  task daily: :environment do
    yesterday = Time.current.to_date
    TakeStatisticsService.call(yesterday)
  end

  task monthly: :environment do
    date_on = 1.month.ago.to_date
    while date_on <= Date.today
      TakeStatisticsService.call(date_on)
      date_on = date_on + 1
    end
  end

  task all: :environment do
    date_on = (ProjectAccessLog.minimum(:created_at) || Time.current).to_date
    while date_on <= Date.today
      TakeStatisticsService.call(date_on)
      date_on = date_on + 1
    end
  end
end
