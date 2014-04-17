class Way < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :description]
  UPDATABLE_COLUMNS = [:description, :photo, :way_set_id]

  include Gitfab::ActsAsItemInRecipe

  belongs_to :way_set
  belongs_to :recipe
  has_many :tools

  def dir_path
    "way_set/#{self.way_set_id}"
  end
end
