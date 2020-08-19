require 'singleton'

class TakeStatisticsService
  include Singleton

  def self.call(date_on)
    instance.call(date_on)
  end

  def call(date_on)
    raise ArgumentError unless date_on.is_a?(Date)

    from = date_on.midnight
    to = date_on.end_of_day
    now = Time.current
  
    statistics = Project.access_ranking(from: from, to: to, limit: Project.count).map do |project|
      ProjectAccessStatistic.new(project: project, date_on: date_on, access_count: project.access_count)
    end
    ProjectAccessStatistic.import(statistics)
  end
end
