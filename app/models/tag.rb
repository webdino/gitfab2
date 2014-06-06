class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Contributable

  embedded_in :taggable, polymorphic: true

  field :name

  class << self
    def updatable_columns
      [:name]
    end
  end
end
