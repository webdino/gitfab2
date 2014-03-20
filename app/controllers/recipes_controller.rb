class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :fork]
  before_action :set_user
  layout "dashboard"

  def index
    if q = params[:q]
      @recipes = @user.recipes.solr_search do
        fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
        case params[:type]
        when "own"
          with :user_id, params[:user_id]
        when "contributed"
          # TODO: Implement
        when "starred"
          # TODO: Implement
        end
      end.results
    else
      @recipes = @user.recipes
    end
  end

  def show
  end

  def new
    @recipe = @user.recipes.build
    @recipe.fill_default_name_for! current_user
  end

  def edit
  end

  def create
    @recipe = @user.recipes.build recipe_params
    @recipe.last_committer = current_user
    if @recipe.save
      redirect_to [@user, @recipe], notice: "Recipe was successfully created."
    else
      render action: :new
    end
  end

  def fork
    new_recipe = @recipe.fork_for! current_user
    if new_recipe.save
      redirect_to [@user, new_recipe], notice: "Recipe was successfully forked."
    else
      @recipe = new_recipe
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
    recipe_id = params[:id] || params[:recipe_id]
    @recipe = Recipe.where(id: recipe_id, user_id: params[:user_id]).first
  end

  def set_user
    @user = User.find params[:user_id]
  end

  def recipe_params
    params.require(:recipe).permit Recipe::UPDATABLE_COLUMNS
  end
end
