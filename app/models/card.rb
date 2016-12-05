class Card < ActiveRecord::Base
  include MongoidStubbable
  include Attachable
  include Figurable
  include Contributable
  include Likable
  include Commentable
  include Forkable
  include Annotatable
  include CardDecorator
  include Searchable

  searchable_field :description

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.annotations = annotations.map(&:dup_document)
      doc.figures = figures.map(&:dup_document)
      doc.attachments = attachments.map(&:dup_document)
    end
  end

  def is_taggable?
    self.is_a? Taggable
  end

  class << self
    def updatable_columns
      [:id, :title, :description, :type,
       figures_attributes: Figure.updatable_columns,
       attachments_attributes: Attachment.updatable_columns,
       likes_attributes: Like.updatable_columns
      ]
    end

    def use_relative_model_naming?
      true
    end
  end
end
