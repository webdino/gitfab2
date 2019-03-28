namespace :npm do
  namespace :run do
    task :build do
      on roles fetch(:npm_roles) do
        within fetch(:npm_target_path, release_path) do
          with fetch(:npm_env_variables, {}) do
            execute :npm, "run build"
          end
        end
      end
    end
  end
end

after "npm:install", "npm:run:build"
