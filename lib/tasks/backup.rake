namespace :backup do
  desc 'Delete backup files'
  task delete: :environment do
    Backup.delete_old_files
  end
end
