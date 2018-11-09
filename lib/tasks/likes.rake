namespace :likes do
  desc 'fix likes_count'
  task fix: :environment do
    Project.find_each do |project|
      project.update_column(:likes_count, project.likes.count)
    end
  end
end
