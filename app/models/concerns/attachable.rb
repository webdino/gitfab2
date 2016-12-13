module Attachable
  extend ActiveSupport::Concern
  included do
    has_many :attachments, as: :attachable, dependent: :destroy do
      Attachment.subclasses.each do |klass|
        define_method klass.model_name.element.pluralize do
          where type: klass.name
        end
      end
    end
    accepts_nested_attributes_for :attachments
  end
end
