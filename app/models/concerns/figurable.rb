module Figurable
  extend ActiveSupport::Concern
  included do
    embeds_many :figures, cascade_callbacks: true
    accepts_nested_attributes_for :figures, allow_destroy: true
  end
end
