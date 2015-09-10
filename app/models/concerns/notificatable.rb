module Notificatable
  extend ActiveSupport::Concern
  included do
    def notify(users, notificator, url, body)
      if users.length > 1
        users.each do |user|
          Notification.create notificatable_url: url,
                              notificatable_type: self.class.name,
                              notifier: notificator,
                              notified: user,
                              body: body
        end
      else
        Notification.create notificatable_url: url,
                            notificatable_type: self.class.name,
                            notifier: notificator,
                            notified: users[0],
                            body: body
      end
    end

    def notifiable_users(current_user, original_project = nil)
      owners = []
      collaborators = []
      project = original_project.present? ? original_project : self
      owner = project.owner
      if owner.is_a? User
        owners << owner
      else
        owners += owner.members
      end
      project.collaborators.each do |collaborator|
        if collaborator.is_a? User
          collaborators << collaborator
        else
          collaborators += collaborator.members
        end
      end
      users = (owners + collaborators).uniq
      users.delete current_user
      users
    end
  end
end
