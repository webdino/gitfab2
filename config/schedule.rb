# 20:00 UTC -> 5:00 JST (+0900)
every 1.day, at: ['20:00'] do
  # https://github.com/javan/whenever/issues/144#issuecomment-3003227
  rake "backup:delete"
end
