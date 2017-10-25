module Taggable
  extend ActiveSupport::Concern
  included do
    has_many :tags, as: :taggable, dependent: :destroy
  end
end
