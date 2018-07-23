namespace :projects_count do
  desc 'fix projects_count'
  task fix: :environment do
    [User, Group].each do |klass|
      klass.find_each do |owner|
        owner.transaction do
          owner.lock!
          owner.update_column(:projects_count, owner.update_projects_count)
        end
      end
    end
  end
end
