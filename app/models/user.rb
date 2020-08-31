# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  authority              :string(255)
#  avatar                 :string(255)
#  email                  :string(255)      not null
#  is_deleted             :boolean          default(FALSE), not null
#  location               :string(255)
#  name                   :string(255)
#  password_digest        :string(255)
#  projects_count         :integer          default(0), not null
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  slug                   :string(255)
#  url                    :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_name   (name) UNIQUE
#  index_users_on_slug   (slug) UNIQUE
#

class User < ApplicationRecord
  include ProjectOwner
  include Collaborator

  extend FriendlyId
  friendly_id :name, use: :slugged

  attr_accessor :encrypted_identity_id # OAuth認証時に使用
  attr_accessor :email_confirmation

  mount_uploader :avatar, AvatarUploader

  has_many :card_comments
  has_many :identities, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_projects, through: :likes, source: :project
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :notifications_given, class_name: 'Notification', inverse_of: :notifier, foreign_key: :notifier_id
  has_many :my_notifications, class_name: 'Notification', inverse_of: :notified, foreign_key: :notified_id
  has_many :project_comments, dependent: :destroy
  has_many :project_access_logs

  validates :name, unique_owner_name: true, name_format: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "format is invalid" }
  validate :confirm_email

  scope :active, -> { where(is_deleted: false) }

  concerning :Draft do
    def generate_draft
      "#{name}\n#{url}\n#{location}"
    end
  end

  def self.create_from_identity(identity, user_attrs = {})
    user = identity.build_user(user_attrs)
    transaction do
      user.save!
      identity.save!
    end
    user
  rescue ActiveRecord::RecordInvalid
    user
  end

  def is_system_admin?
    authority == 'admin'
  end

  def is_owner_of?(project)
    self == project.owner
  end

  def is_contributor_of?(card)
    card.contributions.exists?(contributor_id: id)
  end

  def password_auth?
    false
  end

  def membership_in(group)
    memberships.find_by group_id: group.id
  end

  def is_admin_of?(group)
    return false unless group
    group.admins.exists?(id)
  end

  def is_editor_of?(group)
    return false unless group
    group.editors.exists?(id)
  end

  def is_member_of?(group)
    return false unless group
    group.members.exists?(id)
  end

  def is_project_manager?(project)
    if project.owner_type == Group.name
      is_admin_of = is_admin_of?(project.owner)
    end
    is_admin_of || is_owner_of?(project) || is_collaborator_of?(project)
  end

  def join_to(group)
    memberships.find_or_create_by group_id: group.id
  end

  def is_in_collaborated_group?(project)
    is_in_collaborated_group = false
    project.collaborators.each do |collaborator|
      if collaborator.class.name == Group.name
        is_in_collaborated_group ||= self.is_member_of?(collaborator)
      end
    end
    is_in_collaborated_group
  end

  def connected_with_github?
    connected_with?("github")
  end

  def connected_with_google?
    connected_with?("google_oauth2")
  end

  def connected_with_facebook?
    connected_with?("facebook")
  end

  def resign!
    transaction do
      remove_avatar!
      identities.destroy_all
      projects.soft_destroy_all!
      memberships.destroy_all
      likes.destroy_all
      card_comments.update_all(body: '（このユーザーは退会しました）')
      project_comments.update_all(body: '（このユーザーは退会しました）')
      my_notifications.destroy_all
      notifications_given.destroy_all
      collaborations.destroy_all
      deleted_user_name = "deleted-user-#{SecureRandom.uuid}"
      update!(
        email: "#{deleted_user_name}@fabble.cc",
        email_confirmation: "#{deleted_user_name}@fabble.cc",
        name: deleted_user_name,
        url: nil,
        location: nil,
        authority: nil,
        password_digest: nil,
        is_deleted: true
      )
    end
  end

  private

    def should_generate_new_friendly_id?
      name_changed? || super
    end

    def confirm_email
      return if email_confirmation.blank? && !email_changed?
      if email != email_confirmation
        errors.add(:base, "Email confirmation does not match Email")
      end
    end

    def connected_with?(provider)
      identities.exists?(provider: provider)
    end
end
