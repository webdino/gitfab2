class Group < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :url, :location]
  UPDATABLE_COLUMNS = [:name, :avatar, :url, :location]

  include MongoidStubbable
  include ProjectOwner
  include Collaborator

  mount_uploader :avatar, AvatarUploader

  validates :name, presence: true, uniqueness: true, unique_owner_name: true, name_format: true

  def members
    User.where 'memberships.group_id' => id
  end

  Membership::ROLE.keys.each do |role|
    define_method role.to_s.pluralize do
      members.where('memberships.role' => Membership::ROLE[role])
    end
  end

  def normalize_friendly_id(value)
    value.to_s.parameterize.present? ? value.to_s.parameterize : value
  end
end
