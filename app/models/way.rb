class Way < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:description, :photo]

  include Gitfab::ActsAsItemInRecipe

  belongs_to :status
  has_many :tools

  before_save ->{self.recipe_id = status.recipe_id}
end
