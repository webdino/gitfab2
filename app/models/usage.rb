class Usage < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:title, :description]
  UPDATABLE_COLUMNS = [:title ,:description, :photo]

  include Gitfab::ActsAsItemInRecipe

end
