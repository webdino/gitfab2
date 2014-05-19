class Group < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name]
  UPDATABLE_COLUMNS = [:name, :avatar]

  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]
  mount_uploader :avatar, AvatarUploader

  has_many :memberships, foreign_key: :group_id
  has_many :members, through: :memberships, source: :user
  has_many :recipes, as: :owner, dependent: :destroy

  validates :name, presence: true, uniqueness: true,
    unique_owner_name: true, name_format: true

  Membership::ROLE.keys.each do |role|
    define_method role.to_s.pluralize do
      self.members.joins(:memberships)
        .where "memberships.role" => Membership::ROLE[role]
    end

    define_method "add_#{role}" do |user|
      self.memberships.create user: user, role: Membership::ROLE[role]
    end
  end

  private
  def should_generate_new_friendly_id?
    name_changed?
  end
end
