# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  authority       :string(255)
#  avatar          :string(255)
#  email           :string(255)
#  fullname        :string(255)
#  location        :string(255)
#  name            :string(255)
#  password_digest :string(255)
#  projects_count  :integer          default(0), not null
#  slug            :string(255)
#  url             :string(255)
#  created_at      :datetime
#  updated_at      :datetime
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

  mount_uploader :avatar, AvatarUploader

  has_many :card_comments
  has_many :identities, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :notifications_given, class_name: 'Notification', inverse_of: :notifier, foreign_key: :notifier_id
  has_many :my_notifications, class_name: 'Notification', inverse_of: :notified, foreign_key: :notified_id

  accepts_nested_attributes_for :memberships, allow_destroy: true

  validates :name, unique_owner_name: true, name_format: true

  concerning :Draft do
    def generate_draft
      "#{name}\n#{fullname}\n#{url}\n#{location}"
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
    card.contributions.each do |contribution|
      return true if contribution.contributor_id == self.id
    end
    false
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

  private

    def should_generate_new_friendly_id?
      name_changed? || super
    end
end
