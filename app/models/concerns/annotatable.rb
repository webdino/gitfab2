module Annotatable
  extend ActiveSupport::Concern
  included do
    embeds_many :annotations, class_name: Card::Annotation.name, as: :annotatable, cascade_callbacks: true
    accepts_nested_attributes_for :annotations
  end
end
