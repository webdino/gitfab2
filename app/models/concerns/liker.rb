module Liker
  extend ActiveSupport::Concern
  included do
    def liked? likeable
      likeable.likes.where(liker: self).exists?
    end
  end
end
