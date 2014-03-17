class Tool < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:name, :description, :photo, :remove_photo]
  belongs_to :recipe
  belongs_to :way
  mount_uploader :photo, PhotoUploader
end
