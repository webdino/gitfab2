class Like < ActiveRecord::Base
  include Contributable

  belongs_to :liker, class_name: 'User'
  belongs_to :likable, polymorphic: true
  validates_uniqueness_of :liker_id, scope: :likable

  class << self
    def updatable_columns
      [:_destroy, :id, :liker_id]
    end
  end
end
