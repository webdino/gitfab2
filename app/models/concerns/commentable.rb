module Commentable
  extend ActiveSupport::Concern
  included do
    if respond_to?(:has_many)
      has_many :comments, as: :commentable, dependent: :destroy
    else
      embeds_many :comments, as: :commentable
    end
    accepts_nested_attributes_for :comments, allow_destroy: true
  end
end
