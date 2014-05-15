class Way < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:description, :photo, :video_id, :status_id, :reassoc_token]

  include Gitfab::ActsAsItemInRecipe
  include Gitfab::HasVideoOrPhoto

  belongs_to :recipe
  belongs_to :status
  belongs_to :creator, class_name: User.name
  has_many :tools

  delegate :recipe, to: :status

  def dir_path
    "statuses/#{self.status_id}/ways"
  end

  def youtube_embed_url
    "#{YOUTUBE_EMBED_URL_BASE}#{self.video_id}"
  end

end
