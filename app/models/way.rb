class Way < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:description, :photo]

  acts_as_list_in_recipe
  mount_uploader :photo, PhotoUploader

  belongs_to :status
  has_many :tools
end
