namespace :likes do
  desc 'fix likes_count'
  task fix: :environment do
    Project.find_each do |obj|
      obj.update_column(:likes_count, obj.likes.count)
    end
  end
end
