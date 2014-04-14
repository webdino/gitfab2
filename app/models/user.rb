class User < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:name, :avatar]

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  acts_as_voter

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  mount_uploader :avatar, AvatarUploader

  has_many :recipes
  has_many :contributor_recipes, foreign_key: :contributor_id
  has_many :contributing_recipes, through: :contributor_recipes, source: :recipe
  has_many :memberships, foreign_key: :user_id, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :collaborating_recipes, through: :collaborations, source: :recipe
  has_many :collaborations, foreign_key: :user_id, dependent: :destroy

  after_save :ensure_dir_exist!

  validates :email, presence: true
  validates :name, :email, uniqueness: true

  def dir_path
    return nil unless self.name.present?
    "#{Settings.git.repo_dir}/#{self.name}"
  end

  def is_owner_of? recipe
    self == recipe.user
  end

  def is_collaborator_of? recipe
    recipe.collaborators.include? self
  end

  def is_creator_of? group
    return false unless group
    self == group.creator
  end

  def can_manage? recipe
    is_owner_of?(recipe) || is_collaborator_of?(recipe) || is_member_of?(recipe.group)
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
end
