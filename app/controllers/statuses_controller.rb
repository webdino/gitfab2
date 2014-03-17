class StatusesController < ApplicationController
  before_action :set_recipe

  def update
    @status = @recipe.statuses.find params[:id]
    @status.update_attributes status_params
    render "recipes/update_elem", locals: {object: @status}
  end

  private
  def status_params
    params.require(:status).permit Status::UPDATABLE_COLUMNS
  end

  def set_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
