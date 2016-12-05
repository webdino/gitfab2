module Taggable
  extend ActiveSupport::Concern
  included do
    if respond_to?(:has_many)
      has_many :tags, as: :taggable
    else
      embeds_many :tags, as: :taggable
    end
  end
end
