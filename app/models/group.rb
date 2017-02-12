class Group < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :url, :location]
  UPDATABLE_COLUMNS = [:name, :avatar, :url, :location]

  include ProjectOwner
  include Collaborator

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :memberships, dependent: :destroy
  has_many :members, class_name: 'User', through: :memberships, source: :user

  mount_uploader :avatar, AvatarUploader

  validates :name, presence: true, uniqueness: true, unique_owner_name: true, name_format: true

  Membership::ROLE.keys.each do |role|
    define_method role.to_s.pluralize do
      members.where('memberships.role' => Membership::ROLE[role])
    end
  end

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end

end
