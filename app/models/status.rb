class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:description, :photo]

  include Gitfab::ActsAsItemInRecipe

  has_many :materials
end
