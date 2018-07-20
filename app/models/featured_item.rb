# == Schema Information
#
# Table name: featured_items
#
#  id               :integer          not null, primary key
#  url              :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  feature_id       :integer
#  target_object_id :string(255)
#
# Indexes
#
#  index_featured_items_feature_id  (feature_id)
#
# Foreign Keys
#
#  fk_featured_items_feature_id  (feature_id => features.id)
#

class FeaturedItem < ApplicationRecord
  belongs_to :feature

  class << self
    def updatable_columns
      [:feature_id, :target_object_id, :url]
    end
  end
end
