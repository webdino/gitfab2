class WaysController < ApplicationController
  before_action :set_recipe

  def update
    @way = @recipe.ways.find params[:id]
    @way.update_attributes way_params
    render "recipes/update_elem", locals: {object: @way}
  end

  private
  def way_params
    params.require(:way).permit (Way::UPDATABLE_COLUMNS + additional_params)
  end

  def additional_params
    [:remove_photo]
  end

  def set_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
