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
  field :kind
  field :content_tmp, type: String

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.content = dup_content if content.present?
    end
  end

  def self.find(id)
    bson_id = Moped::BSON::ObjectId.from_string(id)
    root = Project.where('recipe.states.annotations.attachments._id' => bson_id).first
    if root.present?
      root.recipe.states.each do |state|
        annotation = state.annotations.where('attachments._id' => bson_id).first
        return annotation.attachments.find(id) if annotation.present?
      end
    else
      root = Project.where('recipe.states.attachments._id' => bson_id).first
      sta = root.recipe.states.where('attachments._id' => bson_id).first
      return sta.attachments.find(id)
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
