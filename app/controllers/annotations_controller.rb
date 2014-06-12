class AnnotationsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_recipe
  before_action :load_recipe_card
  before_action :load_annotation, only: [:edit, :update, :destroy]
  before_action :build_annotation, only: :create

  def new
  end

  def edit
  end

  def create
    if @annotation.save
      render :create
    else
      render "errors/failed", status: 400
    end
  end

  def update
    if @annotation.update annotation_params
      render :update
    else
      render "errors/failed", status: 400
    end
  end

  def destroy
    if @annotation.destroy
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

  def load_annotation
    @annotation = @recipe_card.annotations.find params[:id]
  end

  def build_annotation
    @annotation = @recipe_card.annotations.build annotation_params
  end

  def annotation_params
    if params[:annotation]
      params.require(:annotation).permit Card::Annotation.updatable_columns
    end
  end
end
