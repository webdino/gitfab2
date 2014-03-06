class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]
  before_action :set_user

  def index
    @recipes = Recipe.all
  end

  def show
  end

  def new
    @recipe = Recipe.new
  end

  def edit
  end

  def create
    @recipe = Recipe.new recipe_params
    if @recipe.save
      redirect_to [current_user, @recipe], notice: "Recipe was successfully created."
    else
      render action: :new
    end
  end

  def update
    if @recipe.update recipe_params
      redirect_to [current_user, @recipe], notice: "Recipe was successfully updated."
    else
      render action: :edit
    end
  end

  def destroy
    @recipe.destroy
    redirect_to [current_user, :recipes]
  end

  private
    def set_recipe
      @recipe = Recipe.where(id: params[:id], user_id: params[:user_id]).first
    end

    def set_user
      @user = User.find params[:user_id]
    end

    def recipe_params
      params.require(:recipe).permit :user_id, :title, :description, :user_id
    end
end
