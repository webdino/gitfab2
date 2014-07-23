class StatesController < RecipeCardsController
  authorize_resource class: Card::State.name
end
