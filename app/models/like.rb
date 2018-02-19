class Like < ActiveRecord::Base
  include Contributable

  belongs_to :liker, class_name: 'User', required: true
  belongs_to :likable, polymorphic: true, counter_cache: :likes_count, required: true
  validates_uniqueness_of :liker_id, scope: :likable

  class << self
    def updatable_columns
      [:_destroy, :id, :liker_id]
    end
  end
end
