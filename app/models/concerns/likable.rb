module Likable
  extend ActiveSupport::Concern
  included do
    has_many :likes, as: :likable, dependent: :destroy
    accepts_nested_attributes_for :likes, allow_destroy: true
  end
end
