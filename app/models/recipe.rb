class Recipe
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :project
  embeds_many :recipe_cards, cascade_callbacks: true, class_name: Card::RecipeCard.name
  embeds_many :states, cascade_callbacks: true, class_name: "Card::State"
  accepts_nested_attributes_for :states

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.states = states.map{|c| c.dup_document}
    end
  end
end
