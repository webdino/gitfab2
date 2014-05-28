module Attachable
  extend ActiveSupport::Concern
  included do
    embeds_many :attachments, cascade_callbacks: true do
      Attachment.subclasses.each do |klass|
        define_method klass.model_name.element.pluralize do
          where _type: klass.name
        end
      end
    end
    accepts_nested_attributes_for :attachments
  end
end
