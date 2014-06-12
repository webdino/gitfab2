class DerivativeCardsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_recipe
  before_action :load_recipe_card
  before_action :load_derivative, only: [:edit, :update, :destroy]
  before_action :build_derivative, only: :create

  def new
  end

  def edit
  end

  def create
    if @derivative.save
      render :create
    else
      render "errors/failed", status: 400
    end
  end

  def update
    if @derivative.update derivative_params
      render :update
    else
      render "errors/failed", status: 400
    end
  end

  def destroy
    if @derivative.destroy
      render :destroy
    else
      render "errors/failed", status: 400
    end
  end

  private
  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = User.find(owner_id) || Group.find(owner_id)
  end

  def load_project
    @project = @owner.projects.find params[:project_id]
  end

  def load_recipe
    @recipe = @project.recipe
  end

  def load_recipe_card
    @recipe_card = @recipe.recipe_cards.find params[:recipe_card_id]
  end

  def load_derivative
    @derivative = @recipe_card.derivatives.find params[:id]
  end

  def build_derivative
    @derivative = @recipe_card.derivatives.build derivative_params
  end

  def derivative_params
    if params[:derivative]
      params.require(:derivative).permit Card::State.updatable_columns
    end
  end
end
