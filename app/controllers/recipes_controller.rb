class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]
  before_action :set_user, except: :search

  def search
    q = params[:q] || ""
    @recipes = Recipe.solr_search do
      fulltext q.split.map{|word| "\"#{word}\""}.join(" AND ")
    end.results
  end

  def index
    @recipes = @user.recipes
  end

  def show
  end

  def new
    @recipe = Recipe.new
    @recipe.materials.build
    @recipe.tools.build
    @recipe.statuses.build
    @recipe.ways.build
  end

  def edit
  end

  def create
    if fr_id = params[:forked_recipe_id]
      @recipe = Recipe.find(fr_id).fork_for current_user
    else
      @recipe = @user.recipes.build recipe_params
      @recipe.last_committer = current_user
    end
    if @recipe.save
      redirect_to [@user, @recipe], notice: "Recipe was successfully created."
    else
      render action: :new
    end
  end

  def update
    @recipe.last_committer = current_user
    if @recipe.update recipe_params
      redirect_to [@user, @recipe], notice: "Recipe was successfully updated."
    else
      render action: :edit
    end
  end

  def destroy
    @recipe.destroy
    redirect_to [@user, :recipes]
  end

  private
  def set_recipe
    @recipe = Recipe.where(id: params[:id], user_id: params[:user_id]).first
  end

  def set_user
    @user = User.find params[:user_id]
  end

  def recipe_params
    params.require(:recipe).permit Recipe::UPDATABLE_COLUMNS
  end
end
