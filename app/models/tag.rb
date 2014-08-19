class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Contributable
  belongs_to :user

  embedded_in :taggable, polymorphic: true

  field :name

  class << self
    def updatable_columns
      [:_destroy, :name, :user_id]
    end
  end
end
