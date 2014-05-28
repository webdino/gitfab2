class Recipe
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :project
  embeds_many :recipe_cards, cascade_callbacks: true, class_name: Card::RecipeCard.name do
    def states
      where _type: Card::State.name
    end

    def transitions
      where _type: Card::Transition.name
    end
  end

  accepts_nested_attributes_for :recipe_cards

  def dup_document
    dup.tap do |doc|
      doc.id = BSON::ObjectId.new
      doc.recipe_cards = recipe_cards.map{|c| c.dup_document}
    end
  end
end
