class Material < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:id, :name, :url, :quantity, :size, :description, :photo, :_destroy]

  include Gitfab::ActsAsItemInRecipe

  acts_as_paranoid

  belongs_to :status
end
