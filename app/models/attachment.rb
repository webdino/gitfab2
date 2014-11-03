class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic


  mount_uploader :content, AttachmentUploader

  embedded_in :attachable, polymorphic: true

  field :markup_id
  field :link
  field :title
  field :description

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.content = dup_content if content.present?
    end
  end

  class << self
    def updatable_columns
      [:id, :content, :link, :_type, :title, :description, :markup_id]
    end
  end

  private
  def dup_content
    ActionDispatch::Http::UploadedFile.new filename: content.file.filename,
      type: content.file.content_type, tempfile: File.open(content.path)
  end
end
