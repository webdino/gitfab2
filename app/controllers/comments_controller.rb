class CommentsController < ApplicationController
  before_action :load_commentable, only: [:create, :update]
  before_action :build_comment, only: :create
  before_action :load_comment, only: [:update, :destroy]

  authorize_resource

  def create
    if @comment.save
      render :create
    else
      render :failed
    end
  end

  def update
    if @comment.update_attributes comment_params
      render :update
    else
      render :failed
    end
  end

  def destroy
    @comment.destroy
  end

  private
  def load_commentable
    @commentable = comment_params[:commentable_type].camelize.constantize
      .find comment_params[:commentable_id]
  end

  def build_comment
    @comment = @commentable.comments.build comment_params
  end

  def load_comment
    @comment = Comment.find params[:id]
  end

  def comment_params
    if params[:comment]
      params.require(:comment).permit Comment::UPDATABLE_COLUMNS
    end
  end
end
