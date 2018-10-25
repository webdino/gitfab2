class BackupJob < ApplicationJob
  queue_as :default

  def perform(user)
    Backup.new(user).create
    UserMailer.backup(user).deliver_now
  end
end
