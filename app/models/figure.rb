class Figure < ActiveRecord::Base

  mount_uploader :content, FigureUploader
  # TODO: required: true を付けられるかどうか要検討
  belongs_to :figurable, polymorphic: true

  def dup_document
    dup.tap do |doc|
      doc.content = content&.file
    end
  end

  class << self
    def updatable_columns
      [:id, :link, :content, :_destroy]
    end
  end
end
