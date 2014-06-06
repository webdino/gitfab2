class Group
  FULLTEXT_SEARCHABLE_COLUMNS = [:name]
  UPDATABLE_COLUMNS = [:name, :avatar]

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include ProjectOwner

  mount_uploader :avatar, AvatarUploader

  field :name
  field :avatar
  slug :name

  #has_many :recipes, as: :owner, dependent: :destroy

  validates :name, presence: true, uniqueness: true,
    unique_owner_name: true, name_format: true

  def members
    User.where "memberships.group_id" => id
  end

  Membership::ROLE.keys.each do |role|
    define_method role.to_s.pluralize do
      members.where("memberships.role" => Membership::ROLE[role])
    end
  end
end
