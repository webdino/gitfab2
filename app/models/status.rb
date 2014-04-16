class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:description, :photo, :position]

  include Gitfab::ActsAsItemInRecipe

  has_many :materials
  has_one :way_set

  accepts_nested_attributes_for :way_set, allow_destroy: true

  def way_set
    super || build_way_set
  end
end
