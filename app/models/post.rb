class Post < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :recipe_id, :title, :body]

  belongs_to :recipe

  paginates_per 10
end