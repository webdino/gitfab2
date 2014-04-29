class Tool < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:name, :url, :description, :photo]

  include Gitfab::ActsAsItemInRecipe

  acts_as_paranoid

  belongs_to :way
end
