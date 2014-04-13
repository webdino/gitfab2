class Post < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :recipe_id, :title, :body]

  acts_as_commentable

  belongs_to :recipe

  paginates_per 10
end
