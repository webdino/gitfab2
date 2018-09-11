# == Schema Information
#
# Table name: groups
#
#  id             :integer          not null, primary key
#  avatar         :string(255)
#  location       :string(255)
#  name           :string(255)
#  projects_count :integer          default(0), not null
#  slug           :string(255)
#  url            :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_users_on_name  (name) UNIQUE
#  index_users_on_slug  (slug) UNIQUE
#

class Group < ApplicationRecord
  UPDATABLE_COLUMNS = [:name, :avatar, :url, :location]

  include ProjectOwner
  include Collaborator

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :memberships, dependent: :destroy
  has_many :members, class_name: 'User', through: :memberships, source: :user

  mount_uploader :avatar, AvatarUploader

  validates :name, presence: true, unique_owner_name: true, name_format: true

  Membership::ROLE.keys.each do |role|
    define_method role.to_s.pluralize do
      members.where('memberships.role' => Membership::ROLE[role])
    end
  end

  concerning :Draft do
    def generate_draft
      "#{name}\n#{url}\n#{location}"
    end
  end

  private

    def should_generate_new_friendly_id?
      name_changed? || super
    end

end
