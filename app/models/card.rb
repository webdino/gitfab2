class Card < ActiveRecord::Base
  include Attachable
  include Figurable
  include Contributable
  include Likable
  include Commentable
  include CardDecorator

  validates :type, presence: true

  def dup_document
    dup_klass = type.present? ? type.constantize : Card
    becomes(dup_klass).dup.tap do |doc|
      doc.figures = figures.map(&:dup_document)
      doc.attachments = attachments.map(&:dup_document)
      doc.comments = []
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
