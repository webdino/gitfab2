class AnnotationsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_recipe
  before_action :load_recipe_card
  before_action :load_annotation, only: [:edit, :update, :destroy]
  before_action :build_annotation, only: [:new, :create]
  before_action :update_contribution, only: [:create, :update]

  authorize_resource class: Card::Annotation.name

  def new
  end

  def edit
  end

  def create
    if @annotation.save
      render result_view
    else
      render "errors/failed", status: 400
    end
  end

  def update
    if @annotation.update annotation_params
      render result_view
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
  def result_view
    klass = @recipe_card.class
    view_name = "#{parametize(klass)}_annotation"
  end

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
    Card::RecipeCard.subclasses.each do |klass|
      parameter_name = "#{parametize(klass)}_id"
      if params[parameter_name]
        @recipe_card = @recipe.recipe_cards.find params[parameter_name]
        break
      end
    end
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

  def parametize klass
    klass.to_s.split(/::/).last.downcase
  end

  def update_contribution
    unless current_user
      return
    end
    @annotation.contributions.each do |contribution|
      if contribution.contributor_id == current_user.slug
        contribution.updated_at = DateTime.now
        return
      end
    end
    contribution = @annotation.contributions.new
    contribution.contributor_id = current_user.slug
    contribution.created_at = DateTime.now
    contribution.updated_at = DateTime.now
  end
end
