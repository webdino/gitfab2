class Recipe < ActiveRecord::Base

  belongs_to :project, required: true
  has_many :states, ->{ order(:position) }, class_name: 'Card::State', dependent: :destroy
  has_many :recipe_cards, ->{ order(:position) }, class_name: 'Card::RecipeCard', dependent: :destroy
  accepts_nested_attributes_for :states

  def dup_document
    dup.tap do |doc|
      doc.states = states.map(&:dup_document)
    end
  end
end
