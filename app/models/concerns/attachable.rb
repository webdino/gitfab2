module Attachable
  extend ActiveSupport::Concern
  included do
    if respond_to?(:has_many)
      has_many :attachments, as: :attachable, dependent: :destroy do
        Attachment.subclasses.each do |klass|
          define_method klass.model_name.element.pluralize do
            where type: klass.name
          end
        end
      end
    else
      embeds_many :attachments, cascade_callbacks: true do
        Attachment.subclasses.each do |klass|
          define_method klass.model_name.element.pluralize do
            where _type: klass.name
          end
        end
      end
    end
    accepts_nested_attributes_for :attachments
  end
end
