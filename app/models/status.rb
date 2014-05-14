class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:id, :description, :photo, :video_id, :position, :reassoc_token, :_destroy]
  YOUTUBE_EMBED_URL_BASE = "http://www.youtube.com/embed/"

  include Gitfab::ActsAsItemInRecipe


  has_many :materials
  has_many :ways, dependent: :destroy

  accepts_nested_attributes_for :ways, allow_destroy: true

  before_validation ->{self.reassoc_token ||= SecureRandom.hex 20}

  def dup_with_photo_and_ways
    new_status = self.dup_with_photo
    self.ways.each do |way|
      new_status.ways << way.dup_with_photo
    end
    new_status
  end

  def youtube_embed_url
    "#{YOUTUBE_EMBED_URL_BASE}#{self.video_id}"
  end

end
