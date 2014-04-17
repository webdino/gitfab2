class Tool < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:id, :name, :url, :description, :photo, :_destroy]

  include Gitfab::ActsAsItemInRecipe

  belongs_to :way
end
