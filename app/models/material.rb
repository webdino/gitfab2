class Material < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:name, :description, :photo]
  belongs_to :recipe
  belongs_to :status
  mount_uploader :photo, PhotoUploader
  acts_as_list_in_recipe
end
