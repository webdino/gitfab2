class MaterialsController < ApplicationController
  before_action :set_recipe

  def create
    @material = @recipe.materials.create material_params
    render "recipes/update_elem", locals: {item: @material}
  end

  def update
    @material = @recipe.materials.find params[:id]
    @material.update_attributes material_params
    render "recipes/update_elem", locals: {item: @material}
  end

  private
  def material_params
    params.require(:material).permit (Material::UPDATABLE_COLUMNS + additional_params)
  end

  def additional_params
    [:remove_photo]
  end

  def set_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
