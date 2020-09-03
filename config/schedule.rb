# 20:00 UTC -> 5:00 JST (+0900)
every 1.day, at: ['20:00'] do
  rake "backup:delete"
end

every 1.day, at: ['00:30'] do
  rake 'statistic:daily'
end

every 1.hour do
  runner 'Rails.cache.clear'
end
