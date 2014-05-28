class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :content, AttachmentUploader
  
  embedded_in :attachable, polymorphic: true

  field :link

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.content = dup_content if content.present?
    end
  end

  class << self
    def updatable_columns
      [:id, :content, :link]
    end
  end

  private
  def dup_content
    ActionDispatch::Http::UploadedFile.new filename: content.file.filename,
      type: content.file.content_type, tempfile: File.open(content.path)
  end
end
