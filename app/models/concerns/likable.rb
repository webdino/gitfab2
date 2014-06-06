module Likable
  extend ActiveSupport::Concern
  included do
    embeds_many :likes, as: :likable
    accepts_nested_attributes_for :likes, allow_destroy: true
  end
end
