class ToolsController < ApplicationController
  before_action :set_recipe

  def update
    @tool = @recipe.tools.find params[:id]
    @tool.update_attributes tool_params
    render "recipes/update_elem", locals: {object: @tool}
  end

  private
  def tool_params
    params.require(:tool).permit Way::UPDATABLE_COLUMNS
  end

  def set_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
