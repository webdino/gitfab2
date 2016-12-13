class Recipe < ActiveRecord::Base

  belongs_to :project
  has_many :states, class_name: 'Card::State', dependent: :destroy
  has_many :recipe_cards, class_name: 'Card::RecipeCard', dependent: :destroy
  accepts_nested_attributes_for :states

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.states = states.map(&:dup_document)
    end
  end
end
