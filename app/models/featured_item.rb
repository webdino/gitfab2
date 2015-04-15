class FeaturedItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :feature

  field :target_object_id
  field :url

  class << self
    def updatable_columns
      [:feature_id, :target_object_id, :url]
    end
  end
end
