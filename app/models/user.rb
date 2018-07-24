# == Schema Information
#
# Table name: users
#
#  id             :integer          not null, primary key
#  authority      :string(255)
#  avatar         :string(255)
#  email          :string(255)      default(""), not null
#  fullname       :string(255)
#  location       :string(255)
#  name           :string(255)
#  projects_count :integer          default(0), not null
#  provider       :string(255)
#  slug           :string(255)
#  uid            :string(255)
#  url            :string(255)
#  created_at     :datetime
#  updated_at     :datetime
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

  mount_uploader :avatar, AvatarUploader

  has_many :likes, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :notifications_given, class_name: 'Notification', inverse_of: :notifier, foreign_key: :notifier_id
  has_many :my_notifications, class_name: 'Notification', inverse_of: :notified, foreign_key: :notified_id

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, if: -> { self.persisted? }
  validates :name, unique_owner_name: true,
                   name_format: true, if: -> { name.present? }

  concerning :Draft do
    def generate_draft
      "#{name}\n#{fullname}\n#{url}\n#{location}"
    end
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

  def membership_in(group)
    memberships.find_by group_id: group.id
  end

  [:admin, :editor, :member].each do |role|
    define_method "is_#{role}_of?" do |group|
      return false unless group
      group.send(role.to_s.pluralize).include? self
    end
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

  class << self
    def find_for_github_oauth(auth)
      find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.name = auth.info.nickname
        user.fullname = auth.info.name
        user.remote_avatar_url = auth.info.image
      end
    end

    def updatable_columns
      [:avatar, :url, :location]
    end
  end

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
