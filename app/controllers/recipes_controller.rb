class RecipesController < ApplicationController
  layout "project"

  before_action :load_owner
  before_action :load_project
  before_action :load_recipe

  #authorize_resource

  def show
  end

  def update
    if @recipe.update recipe_params
      render :update
    else
      render "errors/failed", status: 400
    end
  end

  private
  def recipe_params
    if params[:recipe]
      w_list = Card::RecipeCard.updatable_columns
      w_list << {derivatives_attributes: Card::RecipeCard.updatable_columns}
      w_list << {annotations_attributes: Card::Annotation.updatable_columns}
      params.require(:recipe)
        .permit recipe_cards_attributes: w_list
    end
  end

  def load_owner
    if params[:owner_name]
      @owner ||= User.find params[:owner_name]
      @owner ||= Group.find params[:owner_name]
    end
  end

  def load_project
    @project = @owner.projects.find params[:project_id]
  end

  def load_recipe
    @recipe = @project.recipe
  end
end
