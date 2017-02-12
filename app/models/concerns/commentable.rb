module Commentable
  extend ActiveSupport::Concern
  included do
    has_many :comments, as: :commentable, dependent: :destroy
    accepts_nested_attributes_for :comments, allow_destroy: true
  end
end
