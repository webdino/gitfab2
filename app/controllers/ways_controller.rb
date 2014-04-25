class WaysController < ApplicationController
  before_action :load_owner
  before_action :load_recipe
  before_action :load_status
  before_action :build_way, only: [:create]
  before_action :load_way, only: [:update, :destroy]
  after_action  :update_and_commit_recipe, only: [:create, :update, :destroy]
  after_action :add_contributor, only: [:create, :update, :destroy]

  authorize_resource

  def create
    @way.save
    render "recipes/create_item", locals: {item: @way}
  end

  def update
    @way.update_attributes way_params
    render "recipes/update_item", locals: {item: @way}
  end

  def destroy
    @way.destroy
    render "recipes/destroy_item"
  end

  private
  def way_params
    if params[controller_name.singularize]
      resource_name = self.class.name
      params.require(controller_name.singularize)
        .permit (controller_name.classify.constantize::UPDATABLE_COLUMNS + additional_params)
    end
  end

  def additional_params
    [:id, :remove_photo, :_destroy]
  end

  def build_way
    @way = @status.ways.build way_params
  end

  def load_way
    @way = @status.ways.find params[:id]
  end

  def load_status
    @status = @recipe.statuses.find params[:status_id]
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
    @way.recipe.update_attributes last_committer: current_user
  end

  def add_contributor
    unless @way.recipe.owner == current_user
      @way.recipe.contributors << current_user
    end
  end
end
