# == Schema Information
#
# Table name: cards
#
#  id               :integer          not null, primary key
#  annotatable_type :string(255)
#  description      :text(4294967295)
#  position         :integer          default(0), not null
#  title            :string(255)
#  type             :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  annotatable_id   :integer
#  project_id       :integer
#  recipe_id        :integer
#
# Indexes
#
#  index_cards_annotatable  (annotatable_type,annotatable_id)
#  index_cards_project_id   (project_id)
#  index_cards_recipe_id    (recipe_id)
#
# Foreign Keys
#
#  fk_cards_project_id  (project_id => projects.id)
#  fk_cards_recipe_id   (recipe_id => recipes.id)
#

class Card < ActiveRecord::Base
  include Figurable
  include Contributable
  include Commentable

  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments

  validates :type, presence: true
  validate do
    if title.blank? && description.blank?
      errors.add(:base, "cannot make empty card.")
    end
  end

  def dup_document
    dup_klass = type.present? ? type.constantize : Card
    becomes(dup_klass).dup.tap do |doc|
      doc.figures = figures.map(&:dup_document)
      doc.attachments = attachments.map(&:dup_document)
      doc.comments = []
    end
  end

  def htmlclass
    type.split(/::/).last.underscore
  end

  class << self
    def updatable_columns
      [:id, :title, :description, :type,
       figures_attributes: Figure.updatable_columns,
       attachments_attributes: Attachment.updatable_columns
      ]
    end

    def use_relative_model_naming?
      true
    end
  end
end
