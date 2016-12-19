module Annotatable
  extend ActiveSupport::Concern
  included do
    has_many :annotations, class_name: 'Card::Annotation',
             as: :annotatable,
             dependent: :destroy
    accepts_nested_attributes_for :annotations
  end

  def dup_document
    super.tap do |doc|
      doc.annotations = annotations.map(&:dup_document)
    end
  end
end
