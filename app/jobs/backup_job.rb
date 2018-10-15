class BackupJob < ApplicationJob
  queue_as :default

  def perform(user, email)
    Backup.new(user).run
    UserMailer.backup(email, SecureRandom.urlsafe_base64, user).deliver_now
  end
end
