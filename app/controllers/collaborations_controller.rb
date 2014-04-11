class CollaborationsController < ApplicationController

  before_action :load_owner
  before_action :load_recipe
  before_action :load_collaboration, only: :destroy
  before_action :build_collaboration, only: :create

  authorize_resource

  def index
  end

  def create
    if @collaboration.save
      render :create
    else
      render :failed
    end
  end

  def destroy
    @collaboration.destroy
    render :destroy
  end

  private
  def collaboration_params
    if params[:collaboration]
      if user = User.where(slug: params[:collaboration][:user_id]).first
        params[:collaboration][:user_id] = user.id
      end
      params.require(:collaboration).permit [:user_id]
    end
  end

  def build_collaboration
    @collaboration = @recipe.collaborations.build collaboration_params
  end

  def load_collaboration
    @collaboration = @recipe.collaborations.find params[:id]
  end

  def load_recipe
    @recipe = @owner.recipes.find params[:recipe_id]
  end

  def load_owner
    owner_name = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = if User.exists? owner_name
      User.find owner_name
    elsif Group.exists? owner_name
      Group.find owner_name
    end
  end
end
