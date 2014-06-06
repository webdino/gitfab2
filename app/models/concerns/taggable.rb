module Taggable
  extend ActiveSupport::Concern
  included do
    embeds_many :tags, as: :taggable
  end
end
