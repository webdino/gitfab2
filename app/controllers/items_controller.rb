class ItemsController < ApplicationController
  before_action :set_recipe
  before_action :set_parent

  def create
    @item = @parent.send(controller_name).create item_params
    render "recipes/create_item", locals: {item: @item}
  end

  def update
    @item = @parent.send(controller_name).find params[:id]
    @item.update_attributes item_params
    render "recipes/update_item", locals: {item: @item}
  end

  def destroy
    @parent.send(controller_name).find(params[:id]).destroy
    render "recipes/destroy_item"
  end

  private
  def item_params
    resource_name = self.class.name
    params.require(controller_name.singularize)
      .permit (controller_name.classify.constantize::UPDATABLE_COLUMNS + additional_params)
  end

  def additional_params
    [:remove_photo]
  end

  def set_recipe
    @recipe = Recipe.find params[:recipe_id]
  end

  def set_parent
    @parent = @recipe
  end
end
