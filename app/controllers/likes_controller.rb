class LikesController < ApplicationController
  before_action :load_votable, only: [:create, :destroy]
  before_action :build_like, only: :create

  authorize_resource

  def create
    if current_user.likes @votable
      render :create
    else
      render :failed
    end
  end

  def destroy
    current_user.unlike @votable
  end

  private
  def load_votable
    @votable = like_params[:votable_type].camelize.constantize
      .find like_params[:votable_id]
  end

  def build_like
    @like = @votable.likes.build.becomes Like
  end

  def like_params
    if params[:like]
      params.require(:like).permit Like::UPDATABLE_COLUMNS
    end
  end
end
