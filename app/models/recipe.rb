class Recipe < ActiveRecord::Base
  include DraftGenerator

  belongs_to :project, required: true
  has_many :states, ->{ order(:position) }, class_name: 'Card::State', dependent: :destroy, inverse_of: :recipe
  has_many :recipe_cards, ->{ order(:position) }, class_name: 'Card::RecipeCard', dependent: :destroy
  accepts_nested_attributes_for :states

  def generate_draft
    lines = []
    states.each do |state|
      lines << ActionController::Base.helpers.strip_tags(state.description)
    end
    lines.join("\n")
  end

  def dup_document
    dup.tap do |doc|
      doc.states = states.map(&:dup_document)
    end
  end
end
