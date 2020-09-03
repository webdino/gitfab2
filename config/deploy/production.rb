role :app, %w(deploy@localhost)
role :web, %w(deploy@localhost)
role :db,  %w(deploy@localhost)
server 'localhost', user: 'deploy', roles: %w(web app cron)
set :rails_env, 'production'
set :linked_files, %w{config/database.yml config/secrets.yml}
