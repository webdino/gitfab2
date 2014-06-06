module Commentable
  extend ActiveSupport::Concern
  included do
    embeds_many :comments, as: :commentable
  end
end
