module RecipesHelper
  def display_style item
    if Array === item
      item.first.ways.any? ? "display:none":"display:block"
    end
  end

end
