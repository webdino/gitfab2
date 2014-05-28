class Card
  include Mongoid::Document
  include Mongoid::Timestamps
  include Attachable
  include Figurable
  include Contributable
  include Commentable
  include Forkable
  include Annotatable
  include CardDecorator
  include Searchable

  searchable_field :description

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.attachments = attachments.map{|a| a.dup_document}
    end
  end

  class << self
    def updatable_columns
      [:id, :description, :_type,
       figures_attributes: Figure.updatable_columns,
       attachments_attributes: Attachment.updatable_columns]
    end
  end
end
