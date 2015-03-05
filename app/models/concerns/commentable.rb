module Commentable
  extend ActiveSupport::Concern
  included do
    embeds_many :comments, as: :commentable
    accepts_nested_attributes_for :comments, allow_destroy: true
  end
end
