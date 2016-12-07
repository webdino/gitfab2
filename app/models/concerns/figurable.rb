module Figurable
  extend ActiveSupport::Concern
  included do
    if respond_to?(:has_many)
      has_many :figures, as: :figurable, dependent: :destroy
    else
      embeds_many :figures, cascade_callbacks: true
    end
    accepts_nested_attributes_for :figures, allow_destroy: true
  end
end
