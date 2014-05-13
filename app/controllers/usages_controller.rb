class UsagesController < ApplicationController
  before_action :load_owner
  before_action :load_recipe
  before_action :build_usage, only: [:create]
  before_action :load_usage, only: [:update, :destroy]
  after_action  :update_and_commit_recipe, only: [:create, :update, :destroy]

  authorize_resource

  def create
    @usage.save
    render "recipes/create_item", locals: {item: @usage}
  end

  def update
    @usage.update_attributes usage_params
    render "recipes/update_item", locals: {item: @usage}
  end

  def destroy
    @usage.destroy
    render "recipes/destroy_item"
  end

  private
  def usage_params
    if params[:usage]
      params.require(:usage)
        .permit (Usage::UPDATABLE_COLUMNS + additional_params)
    end
  end

  def additional_params
    [:id, :remove_photo, :_destroy]
  end

  def build_usage
    @usage = @recipe.usages.build usage_params
  end

  def load_usage
    @usage = @recipe.usages.find params[:id]
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
    @usage.recipe.update_attributes last_committer: current_user
  end
end
