class Group < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :name, :creator, member_ids: []]

  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]
  mount_uploader :avatar, AvatarUploader

  belongs_to :creator, class_name: User.name
  has_many :memberships, foreign_key: :group_id
  has_many :members, through: :memberships, source: :user
  has_many :recipes

  after_create :add_initial_member

  validates :name, presence: true, uniqueness: true

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
    return nil unless self.name.present?
    ::FileUtils.mkdir_p dir_path
  end
end
