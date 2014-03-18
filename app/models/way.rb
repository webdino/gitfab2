class Way < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:description, :photo]
  belongs_to :status
  has_many :tools
  mount_uploader :photo, PhotoUploader
  acts_as_list_in_recipe
end
