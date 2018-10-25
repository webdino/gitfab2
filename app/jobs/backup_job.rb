class BackupJob < ApplicationJob
  queue_as :default

  def perform(user)
    Backup.new(user).create
    UserMailer.backup(SecureRandom.urlsafe_base64, user).deliver_now
  end
end
