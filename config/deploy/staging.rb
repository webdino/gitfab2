set :rails_env, "staging"
set :deploy_env, "staging"
set :deploy_to, "/usr/local/rails_apps/gitfab2"
set :pid_file, "/tmp/unicorn_gitfab2.pid"

role :web, "localhost"
role :app, "localhost"
role :db, "localhost", primary: true
