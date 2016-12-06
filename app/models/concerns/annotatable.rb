module Annotatable
  extend ActiveSupport::Concern
  included do
    if respond_to?(:has_many)
      has_many :annotations, class_name: 'Card::Annotation',
               as: :annotatable,
               dependent: :destroy
    else
      embeds_many :annotations, class_name: Card::Annotation.name,
                  as: :annotatable,
                  cascade_callbacks: true
    end
    accepts_nested_attributes_for :annotations
  end
end
