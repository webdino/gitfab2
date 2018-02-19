class Tag < ActiveRecord::Base
  include Contributable
  include DraftGenerator
  # TODO: 2つのbelongs_to についてrequired: true を付けることができるか要検討
  belongs_to :user
  belongs_to :taggable, polymorphic: true

  def generate_draft
    "#{name}"
  end

  class << self
    def updatable_columns
      [:_destroy, :name, :user_id]
    end
  end
end
