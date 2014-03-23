class Material < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:name, :description, :photo]

  include Gitfab::ActsAsItemInRecipe

  belongs_to :status
end
