class Tag < ActiveRecord::Base
  include Contributable
  # TODO: 2つのbelongs_to についてrequired: true を付けることができるか要検討
  belongs_to :user
  belongs_to :taggable, polymorphic: true

  class << self
    def updatable_columns
      [:_destroy, :name, :user_id]
    end
  end
end
