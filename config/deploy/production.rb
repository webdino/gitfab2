role :app, %w{deploy@localhost}
role :web, %w{deploy@localhost}
role :db,  %w{deploy@localhost}
server "localhost", user: "deploy", roles: %w{web app}
set :rails_env, "production"
