class Post < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :recipe_id, :title, :body]

  acts_as_commentable
  acts_as_paranoid

  belongs_to :recipe
  belongs_to :user

  validates :title, :body, :recipe_id, presence: true

  paginates_per 10
end
	
