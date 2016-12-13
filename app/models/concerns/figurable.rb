module Figurable
  extend ActiveSupport::Concern
  included do
    has_many :figures, as: :figurable, dependent: :destroy
    accepts_nested_attributes_for :figures, allow_destroy: true
  end
end
