module Forkable
  extend ActiveSupport::Concern
  included do
    embeds_many :derivatives, class_name: name, inverse_of: :original
    embedded_in :original, class_name: name, inverse_of: :derivative

    accepts_nested_attributes_for :derivatives
  end
end
