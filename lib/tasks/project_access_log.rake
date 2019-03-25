require 'csv'

namespace :project_access_log do
  desc 'Create access log from csv'
  task :log_from_csv, [:csv_path, :days] => :environment do |_task, args|
    args.with_defaults(days: '30')
    # CSV ファイルからアクセスログを作成する
    # CSVの形式： /オーナー名/プロジェクト名,アクセス数
    # 例： /takeyuweb/tutorial-1,3
    ::CSV.foreach(args[:csv_path]).with_index(1) do |row, line|
      next if row.blank?

      owner_name, project_name = row[0].split('/').reject(&:empty?)

      # どちらかがない場合、データ不備とみなす
      if owner_name.nil? || project_name.nil?
        puts "line#{line}: #{row[0]} is not found"
        next
      end

      project = Project.active.find_by(slug: project_name, owner: Owner.find_by(owner_name))

      if project
        ProjectAccessLog.log_last_days!(project, row[1].to_i, days: args[:days].to_i)
      else
        puts "line#{line}: #{row[0]} is not found"
      end
    end
  end
end
