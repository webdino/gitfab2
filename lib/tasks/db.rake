namespace :db do
  desc "Re-Create database, db:drop, db:create, db:migrate, db:seed, db:test:prepare"
  task __recreate__: ["db:drop", "db:create", "db:migrate", "db:seed", "db:test:prepare"]
  #task __recreate__: ["db:drop", "db:create", "db:migrate", "db:seed", "sunspot:solr:reindex", "db:test:prepare"]
  task recreate: :environment do
    if Rails.env.development?
      Dir.glob("/home/git/repositories_development/*").each{|path| FileUtils.rm_rf path}
      Rake::Task["db:__recreate__"].invoke
    else
      STDERR.puts "You can run db:recreate only in 'development' env."
      exit 1
    end
  end
end
