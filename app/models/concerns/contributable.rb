module Contributable
  extend ActiveSupport::Concern
  included do
    if respond_to?(:has_many)
      has_many :contributions, as: :contributable, dependent: :destroy
    else
      embeds_many :contributions, as: :contributable
    end
  end
end
