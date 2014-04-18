class Usage < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:id, :description, :photo, :_destroy]

  include Gitfab::ActsAsItemInRecipe

end
