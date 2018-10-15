namespace :backup do
  desc 'Delete backup files under the directory'
  task :delete, [:dirpath, :day] => :environment do |_task, args|
    args.with_defaults(day: 3)
    zip_files = Dir.glob("#{args[:dirpath]}/*")
    zip_files.each do |zip|
      s = File::Stat.new(zip)
      if s.mtime.to_date <= args[:day].to_i.days.ago
        File.delete(zip)
      end
    end
  end
end
