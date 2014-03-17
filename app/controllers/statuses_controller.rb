class StatusesController < ApplicationController
  before_action :set_recipe

  def create
    @status = @recipe.statuses.create status_params
    render "recipes/update_elem", locals: {item: @status}
  end

  def update
    @status = @recipe.statuses.find params[:id]
    @status.update_attributes status_params
    render "recipes/update_elem", locals: {item: @status}
  end

  private
  def status_params
    params.require(:status).permit (Status::UPDATABLE_COLUMNS + additional_params)
  end

  def additional_params
    [:remove_photo]
  end

  def set_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
