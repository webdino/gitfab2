class Recipes::GroupRecipesController < ApplicationController
  layout "dashboard"

  before_action :load_owner
  before_action :build_recipe, only: [:new, :create]
  before_action :load_recipe, only: [:show, :edit, :update, :destroy, :fork]
  before_action :set_last_committer, only: [:create, :update]
  after_action :commit, only: [:create, :update]

  authorize_resource

  def index
    if q = params[:q]
      @recipes = @owner.recipes.solr_search do
        fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
        case params[:type]
        when "own"
          with :owner_id, params[:owner_id]
        when "contributed"
          # TODO: Implement
        when "starred"
          # TODO: Implement
        end
      end.results
    else
      @recipes = @owner.recipes
    end
  end

  def show
  end

  def new
    @recipe.fill_default_name_for! current_owner
  end

  def edit
  end

  def create
    if @recipe.save
      redirect_to [@recipe.owner, @recipe], notice: "Recipe was successfully created."
    else
      render action: :new
    end
  end

  def fork
    new_recipe = @recipe.fork_for! current_owner
    if new_recipe.save
      redirect_to [@owner, new_recipe], notice: "Recipe was successfully forked."
    else
      @recipe = new_recipe
      render action: :new
    end
  end

  def update
    if @recipe.update recipe_params
      redirect_to [@owner, @recipe], notice: "Recipe was successfully updated."
    else
      render action: :edit
    end
  end

  def destroy
    @recipe.destroy
    redirect_to [@owner, :recipes]
  end

  private
  def build_recipe
    @recipe = @owner.recipes.build recipe_params
  end

  def load_recipe
    recipe_id = params[:id] || params[:recipe_id]
    @recipe = @owner.recipes.find recipe_id
  end

  def load_owner
    @owner = User.find params[:owner_id]
  end

  def recipe_params
    if params[:recipe]
      params.require(:recipe).permit Recipe::UPDATABLE_COLUMNS
    end
  end

  def commit
    @recipe.commit!
  end

  def set_last_committer
    @recipe.last_committer = current_owner
  end
end
