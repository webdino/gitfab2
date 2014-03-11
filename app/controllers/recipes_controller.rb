class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]
  before_action :set_owner

  def index
    @recipes = Recipe.all
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
    @recipe = @owner.recipes.create recipe_params
    if @recipe.save
      redirect_to [@owner, @recipe], notice: "Recipe was successfully created."
    else
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
    def set_recipe
      @recipe = Recipe.where(id: params[:id], owner_id: params[:owner_id]).first
    end

    def set_owner
      @owner = (Owner.find params[:owner_id]).becomes Owner
    end

    def recipe_params
      params.require(:recipe).permit Recipe::UPDATABLE_COLUMNS
    end
end
