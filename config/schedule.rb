# 20:00 UTC -> 5:00 JST (+0900)
every 1.day, at: ['20:00'] do
  rake "backup:delete"
end
