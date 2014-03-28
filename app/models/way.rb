class Way < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:description, :photo, :number]

  include Gitfab::ActsAsItemInRecipe

  has_many :tools
end
