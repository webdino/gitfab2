class User < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:name, :avatar]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  mount_uploader :avatar, AvatarUploader

  belongs_to :group
  has_many :recipes
  has_many :contributor_recipes, foreign_key: :contributor_id
  has_many :contributing_recipes, through: :contributor_recipes, source: :recipe
  has_many :star, foreign_key: :user_id
  has_many :starred_recipes, through: :star

  after_save :ensure_dir_exist!

  validates :email, presence: true
  validates :name, :email, uniqueness: true

  def dir_path
    return nil unless self.name.present?
    "#{Settings.git.repo_dir}/#{self.name}"
  end

  private
  def ensure_dir_exist!
    return nil unless self.name.present?
    ::FileUtils.mkdir_p dir_path
  end
end
