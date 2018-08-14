module Notificatable
  extend ActiveSupport::Concern
  included do
    def notify(users, notificator, url, body)
      if users.length > 1
        users.each do |user|
          Notification.create notificatable_url: url, notificatable_type: self.class.name,
                              notifier: notificator, notified: user, body: body
        end
      else
        Notification.create notificatable_url: url, notificatable_type: self.class.name,
                            notifier: notificator, notified: users[0], body: body
      end
    end

    def notifiable_users(current_user)
      users = (managers + collaborate_users).uniq
      users.delete current_user
      users
    end
  end
end
