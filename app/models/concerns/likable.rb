module Likable
  extend ActiveSupport::Concern
  included do
    if respond_to?(:has_many)
      has_many :likes, as: :likable, dependent: :destroy
    else
      embeds_many :likes, as: :likable
    end
    accepts_nested_attributes_for :likes, allow_destroy: true
  end
end
