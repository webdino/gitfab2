class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:description, :photo, :position]

  include Gitfab::ActsAsItemInRecipe

  has_many :materials

  after_create :create_way_set

  private
  def create_way_set
    self.recipe.way_sets.create
  end
end
