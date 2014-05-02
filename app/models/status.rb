class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:id, :description, :photo, :position, :reassoc_token, :_destroy]

  include Gitfab::ActsAsItemInRecipe

  
  has_many :materials
  has_many :ways, dependent: :destroy

  accepts_nested_attributes_for :ways, allow_destroy: true

  def dup_with_photo_and_ways
    new_status = self.dup_with_photo
    self.ways.each do |way|
      new_status.ways << way.dup_with_photo
    end
    new_status
  end

end
