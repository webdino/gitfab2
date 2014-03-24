class ItemsController < ApplicationController
  before_action :set_recipe
  before_action :set_parent
  after_action :commit_recipe, only: [:create, :update, :destroy]

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
    @item = @parent.send(controller_name).find(params[:id])
    @item.destroy
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

  def commit_recipe
    @item.recipe.commit!
  end
end
