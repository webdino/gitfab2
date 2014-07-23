module Contributable
  extend ActiveSupport::Concern
  included do
    embeds_many :contributions, as: :contributable
  end
end