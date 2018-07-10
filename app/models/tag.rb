# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  oldid         :string(255)
#  taggable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  taggable_id   :integer
#  user_id       :integer
#
# Indexes
#
#  index_tags_taggable  (taggable_type,taggable_id)
#  index_tags_user_id   (user_id)
#
# Foreign Keys
#
#  fk_tags_user_id  (user_id => users.id)
#

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
