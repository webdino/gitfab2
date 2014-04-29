class Usage < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:description, :photo]

  include Gitfab::ActsAsItemInRecipe

  acts_as_paranoid

end
