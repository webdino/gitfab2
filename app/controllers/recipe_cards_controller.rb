class RecipeCardsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_recipe
  before_action :build_recipe_card, only: :create
  before_action :load_recipe_card, only: [:edit, :update, :destroy]

  def create
    if @recipe_card.save
      render :create
    else
      render "errors/failed", status: 400
    end
  end

  def update
    if @recipe_card.update recipe_card_params
      render :update
    else
      render "errors/failed", status: 400
    end
  end

  private
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

  def build_recipe_card
    @recipe_card = @recipe.recipe_cards.build recipe_card_params
  end

  def load_recipe_card
    @recipe_card = @recipe.recipe_cards.find params[:id]
  end

  def recipe_card_params
    if params[:card_recipe_card]
      w_list = Card::RecipeCard.updatable_columns + additional_params
      case params[:card_recipe_card][:_type]
      when Card::State.name
      when Card::Transition.name
        w_list << {derivatives_attributes: Card::RecipeCard.updatable_columns}
        w_list << {annotations_attributes: Card::Annotation.updatable_columns}
      end
      params.require(:card_recipe_card).permit w_list
    end
  end

  def additional_params
    [:id, :_type]
  end
end
