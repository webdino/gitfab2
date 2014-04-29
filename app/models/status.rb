class Status < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:description]
  UPDATABLE_COLUMNS = [:id, :description, :photo, :position, :reassoc_token, :_destroy]

  include Gitfab::ActsAsItemInRecipe

  acts_as_paranoid

  has_many :materials
  has_many :ways, dependent: :destroy

  accepts_nested_attributes_for :ways, allow_destroy: true

end
