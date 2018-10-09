# == Schema Information
#
# Table name: attachments
#
#  id              :integer          not null, primary key
#  attachable_type :string(255)      not null
#  content         :string(255)
#  content_tmp     :string(255)
#  description     :string(255)
#  kind            :string(255)
#  link            :text(65535)
#  title           :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  attachable_id   :integer          not null
#  markup_id       :string(255)
#
# Indexes
#
#  index_attachments_attachable  (attachable_type,attachable_id)
#

class Attachment < ApplicationRecord
  mount_uploader :content, AttachmentUploader

  # TODO: optional: trueをとる
  # `accepts_nested_attributes_for :attachments`で親のcreateと同時に子のAttachmentのcreateをすると、
  # 親のIDがまだ存在しないことによってエラーになってしまう。
  # `accepts_nested_attributes_for :attachments`をやめたい。
  belongs_to :attachable, polymorphic: true, optional: true

  def dup_document
    dup.tap do |doc|
      doc.content = content&.file
    end
  end

  class << self
    def updatable_columns
      [:id, :content, :link, :title, :description, :kind, :markup_id]
    end
  end
end
