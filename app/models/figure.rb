class Figure
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  mount_uploader :content, FigureUploader

  embedded_in :figurable, polymorphic: true

  field :link

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.content = dup_content if content.present?
    end
  end

  class << self
    def updatable_columns
      [:id, :link, :content, :_destroy]
    end
  end

  private
  def dup_content
    ActionDispatch::Http::UploadedFile.new filename: content.file.filename,
      type: content.file.content_type, tempfile: File.open(content.path)
  end
end
