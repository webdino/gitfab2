class User < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name]
  UPDATABLE_COLUMNS = [:name, :avatar]

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  acts_as_voter

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  mount_uploader :avatar, AvatarUploader

  has_many :recipes, as: :owner, dependent: :destroy
  has_many :contributor_recipes, foreign_key: :contributor_id
  has_many :contributing_recipes, through: :contributor_recipes, source: :recipe
  has_many :memberships, foreign_key: :user_id, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :collaborating_recipes, through: :collaborations, source: :recipe
  has_many :collaborations, foreign_key: :user_id, dependent: :destroy
  has_many :posts

  after_save :ensure_dir_exist!

  validates :email, presence: true
  validates :name, presence: true, if: ->{self.persisted?}
  validates :name, unique_owner_name: true,
    name_format: true, if: ->{self.name.present?}
  validates :email, uniqueness: true

  def dir_path
    return nil unless self.name.present?
    "#{Settings.git.repo_dir}/#{self.name}"
  end

  def is_owner_of? recipe
    self == recipe.owner
  end

  def is_collaborator_of? recipe
    recipe.collaborators.include? self
  end

  def is_creator_of? group
    return false unless group
    self == group.creator
  end

  def is_admin_of? group
    return false unless group
    group.admins.include? self
  end

  def can_manage? recipe
    if recipe.owner_type == Group.name
      is_member = is_member_of?(recipe.owner)
    end
    is_owner_of?(recipe) || is_collaborator_of?(recipe) || is_member
  end

  [:admin, :editor, :member].each do |role|
    define_method "is_#{role}_of?" do |group|
      return false unless group
      group.send(role.to_s.pluralize).include? self
    end
  end

  private
  def ensure_dir_exist!
    return nil unless self.name.present?
    ::FileUtils.mkdir_p dir_path
  end

  def should_generate_new_friendly_id?
    name_changed?
  end
end
