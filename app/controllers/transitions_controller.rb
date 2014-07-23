class TransitionsController < RecipeCardsController
  authorize_resource class: Card::Transition.name
end