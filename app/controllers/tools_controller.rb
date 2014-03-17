class ToolsController < ApplicationController
  before_action :set_recipe

  def update
    @tool = @recipe.tools.find params[:id]
    @tool.update_attributes tool_params
    render "recipes/update_elem", locals: {object: @tool}
  end

  private
  def tool_params
    params.require(:tool).permit (Tool::UPDATABLE_COLUMNS + additional_params)
  end

  def additional_params
    [:remove_photo]
  end

  def set_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
