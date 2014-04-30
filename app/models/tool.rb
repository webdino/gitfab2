class Tool < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:name, :url, :description, :photo]

  include Gitfab::ActsAsItemInRecipe

  
  belongs_to :way
end
