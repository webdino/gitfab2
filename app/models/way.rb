class Way < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:id, :description, :photo, :status_id, :reassoc_token, :_destroy]

  include Gitfab::ActsAsItemInRecipe

  belongs_to :recipe
  belongs_to :status
  has_many :tools

  delegate :recipe, to: :status

  def dir_path
    "statuses/#{self.status_id}/ways"
  end
end
