class Attachment < ActiveRecord::Base
  mount_uploader :content, AttachmentUploader

  belongs_to :attachable, polymorphic: true

  def dup_document
    dup.tap do |doc|
      doc.content = dup_content if content.present?
    end
  end

  class << self
    def updatable_columns
      [:id, :content, :link, :_type, :title, :description, :kind, :markup_id]
    end
  end

  private

  def dup_content
    ActionDispatch::Http::UploadedFile.new(filename: content.file.filename,
                                           _type: content.file.content_type,
                                           tempfile: File.open(content.path))
  end
end
