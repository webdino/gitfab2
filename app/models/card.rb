# == Schema Information
#
# Table name: cards
#
#  id             :integer          not null, primary key
#  comments_count :integer          default(0), not null
#  description    :text(4294967295)
#  position       :integer          default(0), not null
#  title          :string(255)
#  type           :string(255)      not null
#  created_at     :datetime
#  updated_at     :datetime
#  project_id     :integer
#  state_id       :integer
#
# Indexes
#
#  index_cards_on_state_id  (state_id)
#  index_cards_project_id   (project_id)
#
# Foreign Keys
#
#  fk_cards_project_id  (project_id => projects.id)
#

class Card < ApplicationRecord
  include Figurable

  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments
  has_many :comments, class_name: "CardComment", dependent: :destroy
  has_many :contributions, dependent: :destroy
  has_many :contributors, through: :contributions, class_name: "User"

  validates :type, presence: true
  validate do
    if title.blank? && description.blank?
      errors.add(:base, "cannot make empty card.")
    end
  end

  def dup_document
    dup.tap do |card|
      card.figures = figures.map(&:dup_document)
      card.attachments = attachments.map(&:dup_document)
      card.comments = []
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
