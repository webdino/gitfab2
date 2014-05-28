namespace :db do
  desc "Re-Create database"
  task __recreate__: ["db:drop", "db:create", "db:seed", "sunspot:solr:reindex", "db:test:prepare"]
  task recreate: :environment do
    if Rails.env.development?
      Rake::Task["db:__recreate__"].invoke
    else
      STDERR.puts "You can run db:recreate only in 'development' env."
      exit 1
    end
  end
end
