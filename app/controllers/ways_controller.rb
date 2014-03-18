class WaysController < ApplicationController
  before_action :set_recipe
  before_action :set_status

  def create
    @way = @status.ways.create way_params
    render "recipes/update_elem", locals: {item: @way}
  end

  def update
    @way = @status.ways.find params[:id]
    @way.update_attributes way_params
    render "recipes/update_elem", locals: {item: @way}
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

  def set_status
    @status = @recipe.statuses.find params[:status_id]
  end
end
