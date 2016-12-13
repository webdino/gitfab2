module Annotatable
  extend ActiveSupport::Concern
  included do
    has_many :annotations, class_name: 'Card::Annotation',
             as: :annotatable,
             dependent: :destroy
    accepts_nested_attributes_for :annotations
  end
end
