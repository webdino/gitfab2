# use like below 
# $bundle exec rails runner "eval(File.read 'script/convert.rb')"

Project.all.each do |project|
  recipe = project.recipe

  if recipe.recipe_cards.blank?
    recipe.recipe_cards = []
  end

  if recipe.states.blank?
    recipe.states = []
  end

  recipe.recipe_cards.each do |card|
    state = card.dup_document
    recipe.states << state
    state.save
    card.destroy
  end
end

