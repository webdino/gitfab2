class MaterialsController < ApplicationController
  before_action :set_recipe

  def update
    @material = @recipe.materials.find params[:id]
    @material.update_attributes material_params
    render "recipes/update_elem", locals: {object: @material}
  end

  private
  def material_params
    params.require(:material).permit Material::UPDATABLE_COLUMNS
  end

  def set_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
