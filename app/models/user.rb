class User < Owner
  UPDATABLE_COLUMNS = [:name]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :group
  has_many :contributing_recipes, through: :contributor_recipes, source: :recipe
  has_many :contributor_recipes, foreign_key: :contributor_id
end
