namespace :npm do
  namespace :run do
    task :build do
      on roles fetch(:npm_roles) do
        execute :npm, "run build"
      end
    end
  end
end

after "npm:install", "npm:run:build"
