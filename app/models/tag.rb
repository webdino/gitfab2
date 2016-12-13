class Tag < ActiveRecord::Base
  include MongoidStubbable
  include Contributable
  belongs_to :user

  belongs_to :taggable, polymorphic: true
  after_save :reindex
  after_destroy :reindex

  class << self
    def updatable_columns
      [:_destroy, :name, :user_id]
    end
  end

  private
  def reindex
    taggable.solr_index if taggable.respond_to?(:solr_index)
    true
  end
end
