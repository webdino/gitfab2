class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:description, :photo, :remove_photo]
  has_many :materials
  has_many :prev_ways, class_name: Way.name
  has_many :next_ways, class_name: Way.name
  has_one :next, class_name: Status.name
  belongs_to :prev, class_name: Status.name
  belongs_to :recipe
  mount_uploader :photo, PhotoUploader
end
