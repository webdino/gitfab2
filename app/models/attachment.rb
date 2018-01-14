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
