class ItemsController < ApplicationController
  include ItemsHelper

  before_action :load_owner
  before_action :load_recipe
  before_action :build_item, only: [:create]
  before_action :load_item, only: [:update, :destroy]
  after_action  :update_and_commit_recipe, only: [:create, :update, :destroy]

  def create
    item.save
    render "items/create", locals: {item: item}
  end

  def update
    item.update_attributes item_params
    render "recipes/update_item", locals: {item: item}
  end

  def destroy
    item.destroy
    render "recipes/destroy_item"
  end

  private
  def item_params
    if params[singulized_resource_name]
      resource_name = self.class.name
      params.require(singulized_resource_name)
        .permit (resource_class::UPDATABLE_COLUMNS + additional_params)
    end
  end

  def item_params_for_create
    Hash.new.tap do |resource|
      resource[:photo] = params[:file]
      resource[:name] = params[:text]
    end
  end

  def additional_params
    [:id, :remove_photo, :_destroy]
  end

  def build_item
    self.item = @recipe.send(controller_name).build item_params_for_create
  end

  def load_item
    self.item = @recipe.send(controller_name).find params[:id]
  end

  def load_recipe
    @recipe = @owner.recipes.find params[:recipe_id]
  end

  def load_owner
    if params[:user_id]
      @owner = User.find params[:user_id]
    else
      @owner = Group.find params[:group_id]
    end
  end

  def update_and_commit_recipe
    item.recipe.update_attributes last_committer: current_user
  end

  def singulized_resource_name
    controller_name.singularize
  end

  def resource_class
    controller_name.classify.constantize
  end
end
