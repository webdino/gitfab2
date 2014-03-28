class ItemsController < ApplicationController

  before_action :load_recipe
  before_action :build_item, only: [:create]
  before_action :load_item, only: [:update, :destroy]
  after_action  :update_and_commit_recipe, only: [:create, :update, :destroy]

  authorize_resource through: :recipe
  authorize_resource through: :item, through: :recipe

  def create
    @item.save
    render "recipes/create_item", locals: {item: @item}
  end

  def update
    @item.update_attributes item_params
    render "recipes/update_item", locals: {item: @item}
  end

  def destroy
    @item.destroy
    render "recipes/destroy_item"
  end

  private
  def item_params
    if params[controller_name.singularize]
      resource_name = self.class.name
      params.require(controller_name.singularize)
        .permit (controller_name.classify.constantize::UPDATABLE_COLUMNS + additional_params)
    end
  end

  def additional_params
    [:remove_photo]
  end

  def build_item
    @item = @recipe.send(controller_name).build item_params
  end

  def load_item
    @item = @recipe.send(controller_name).find params[:id]
  end

  def load_recipe
    @recipe = Recipe.find params[:recipe_id]
  end

  def update_and_commit_recipe
    @item.recipe.update_attributes last_committer: current_user
  end
end
