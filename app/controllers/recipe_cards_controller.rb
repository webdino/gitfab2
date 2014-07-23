class RecipeCardsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_recipe
  before_action :build_recipe_card, only: [:new, :create]
  before_action :load_recipe_card, only: [:edit, :update, :destroy]
  before_action :update_contribution, only: [:create, :update]

  def new
  end

  def edit
  end

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

  def destroy
    if @recipe_card.destroy
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
    @recipe_card = @recipe.recipe_cards.find params[:id]
  end

  def build_recipe_card
    @recipe_card = @recipe.recipe_cards.build recipe_card_params
  end

  def recipe_card_params
    key = params[:controller].singularize
    if params[key]
      w_list = Card::RecipeCard.updatable_columns
      w_list << {derivatives_attributes: Card::RecipeCard.updatable_columns}
      params.require(key).permit w_list
    end
  end

  def update_contribution
    unless current_user
      return
    end
    @recipe_card.contributions.each do |contribution|
      if contribution.contributor_id == current_user.slug
        contribution.updated_at = DateTime.now
        return
      end
    end
    contribution = @recipe_card.contributions.new
    contribution.contributor_id = current_user.slug
    contribution.created_at = DateTime.now
    contribution.updated_at = DateTime.now
  end
end
