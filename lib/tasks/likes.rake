namespace :likes do
  desc 'fix likes_count'
  task fix: :environment do
    [Project, Card, Comment].each do |klass|
      klass.find_each do |obj|
        obj.update_column(:likes_count, obj.likes.count)
      end
    end
  end
end
