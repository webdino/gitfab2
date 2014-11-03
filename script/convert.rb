# This is the script for data conversion from recipe.recipe_cards to recipe.states

# 1.ADD
# embeds_many :recipe_cards, cascade_callbacks: true, class_name: Card::RecipeCard.name
# to recipe.rb for conversion

# 2.REMOVE
# private
# in figure.rb

# 3.use this script like
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
    p "-----------------------------------"
    state = card.dup_document
    recipe.states << state
    for num in 0..(state.figures.length - 1) do
        unless card.figures[num].content.blank?
          p "IN:::DUP_CONTENT"
          state.figures[num].content = card.figures[num].dup_content
        else
          p "content is null."
          p card.figures[num].content
        end
    end
    state.figures.each do |fig|
        p fig.content
    end
    p "==================================="
    card.figures.each do |fig|
        p fig.content
    end
    state.save
    card.destroy
    p "                                             "
  end
end
