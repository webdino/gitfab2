module RightHolder
  extend ActiveSupport::Concern
  included do
    has_many :right
  end
end
