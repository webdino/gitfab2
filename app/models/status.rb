class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:id, :description, :photo, :video_id, :position, :reassoc_token, :_destroy]

  include Gitfab::ActsAsItemInRecipe
  include Gitfab::HasVideoOrPhoto

  has_many :materials
  has_many :ways, dependent: :destroy

  accepts_nested_attributes_for :ways, allow_destroy: true

  before_validation ->{self.reassoc_token ||= SecureRandom.hex 20}
  before_update :clear_video_id_or_photo_if_needed

  def dup_with_photo_and_ways
    new_status = self.dup_with_photo
    self.ways.each do |way|
      new_status.ways << way.dup_with_photo
    end
    new_status
  end
end
