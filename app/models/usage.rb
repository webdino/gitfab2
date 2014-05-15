class Usage < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:title, :description]
  UPDATABLE_COLUMNS = [:title, :video_id, :description, :photo]

  include Gitfab::ActsAsItemInRecipe
  include Gitfab::HasVideoOrPhoto
end
