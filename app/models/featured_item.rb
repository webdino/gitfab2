class FeaturedItem < ActiveRecord::Base

  belongs_to :feature, required: true

  class << self
    def updatable_columns
      [:feature_id, :target_object_id, :url]
    end
  end
end
