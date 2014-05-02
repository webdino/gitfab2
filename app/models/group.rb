class Group < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name]
  UPDATABLE_COLUMNS = [:id, :name, :creator, member_ids: []]

  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]
  mount_uploader :avatar, AvatarUploader

  belongs_to :creator, class_name: User.name
  has_many :memberships, foreign_key: :group_id
  has_many :members, through: :memberships, source: :user
  has_many :recipes, as: :owner, dependent: :destroy

  after_create :add_initial_member
  after_save :ensure_dir_exist!

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

  def dir_path
    return nil unless self.name.present?
    "#{Settings.git.repo_dir}/#{self.name}"
  end

  private
  def add_initial_member
    self.memberships.create user: self.creator, role: Membership::ROLE[:admin]
  end

  def ensure_dir_exist!
    return nil if self.name.blank?
    ::FileUtils.mkdir_p dir_path
  end

  def should_generate_new_friendly_id?
    name_changed?
  end
end
