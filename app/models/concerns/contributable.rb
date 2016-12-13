module Contributable
  extend ActiveSupport::Concern
  included do
    has_many :contributions, as: :contributable, dependent: :destroy
  end
end
