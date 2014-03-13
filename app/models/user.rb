class User < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:name]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :group
  has_many :recipes
  has_many :contributing_recipes, through: :contributor_recipes, source: :recipe
  has_many :contributor_recipes, foreign_key: :contributor_id

  after_save :ensure_dir_exist!

  validates :name, :email, presence: true, uniqueness: true

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
