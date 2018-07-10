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
#  oldid           :string(255)
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

class Attachment < ActiveRecord::Base
  mount_uploader :content, AttachmentUploader

  # TODO: require: true を付けるかどうか要検討
  # required: true を付けるとNoteCardsController のspecが落ちる
  belongs_to :attachable, polymorphic: true

  def dup_document
    dup.tap do |doc|
      doc.content = content&.file
    end
  end

  class << self
    def updatable_columns
      [:id, :content, :link, :_type, :title, :description, :kind, :markup_id]
    end
  end
end
