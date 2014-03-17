class Way < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:description, :photo]
  belongs_to :prev_status, class_name: Status.name
  belongs_to :next_status, class_name: Status.name
  has_many :tools
  mount_uploader :photo, PhotoUploader
end
