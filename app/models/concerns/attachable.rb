module Attachable
  extend ActiveSupport::Concern
  included do
    has_many :attachments, as: :attachable, dependent: :destroy
    accepts_nested_attributes_for :attachments
  end
end
