class Figure < ActiveRecord::Base
  include MongoidStubbable

  mount_uploader :content, FigureUploader

  belongs_to :figurable, polymorphic: true

  def dup_document
    dup.tap do |doc|
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
                                           type: content.file.content_type,
                                           tempfile: File.open(content.path)
  end
end
