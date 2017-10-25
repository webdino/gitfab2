role :app, %w(deploy@localhost)
role :web, %w(deploy@localhost)
role :db,  %w(deploy@localhost)
server 'localhost', user: 'deploy', roles: %w(web app)
set :rails_env, 'staging'

namespace :deploy do
  desc 'Upload database.yml'
  task :upload_database_yml do
    on roles(:app) do |_host|
      execute "cp #{release_path}/config/database.ymls/staging.yml #{release_path}/config/database.yml"
    end
  end
  before :starting, 'deploy:upload_database_yml'
end

