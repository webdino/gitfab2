class RecipesController < ApplicationController
  layout "dashboard"

  before_action :load_user
  before_action :build_recipe, only: [:new, :create]
  before_action :load_recipe, only: [:show, :edit, :update, :destroy, :fork]
  after_action :commit, only: [:create, :update]

  authorize_resource

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
    @recipe.fill_default_name_for! current_user
  end

  def edit
  end

  def create
    @recipe.last_committer = current_user
    if @recipe.save
      redirect_to [@recipe.user, @recipe], notice: "Recipe was successfully created."
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
  def build_recipe
    @recipe = @user.recipes.build recipe_params
  end

  def load_recipe
    recipe_id = params[:id] || params[:recipe_id]
    @recipe = Recipe.where(id: recipe_id, user_id: params[:user_id]).first
  end

  def load_user
    @user = User.find params[:user_id]
  end

  def recipe_params
    if params[:recipe]
      params.require(:recipe).permit Recipe::UPDATABLE_COLUMNS
    end
  end

  def commit
    @recipe.commit!
  end
end
