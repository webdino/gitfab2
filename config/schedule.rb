every 1.day, at: ['5:00 am'] do
  # https://github.com/javan/whenever/issues/144#issuecomment-3003227
  rake "backup:delete[#{File.join(Whenever.path, 'tmp', 'backup', 'zip')}]"
end
