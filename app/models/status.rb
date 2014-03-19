class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:description, :photo]

  include Gitfab::UUID

  acts_as_list_in_recipe
  mount_uploader :photo, PhotoUploader

  belongs_to :recipe
  has_many :materials
  has_many :ways
end
