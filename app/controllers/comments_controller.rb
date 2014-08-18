class CommentsController < ApplicationController

  before_action :load_owner
  before_action :load_project
  before_action :load_card
  before_action :build_comment, only: :create
  before_action :load_comment, only: :destroy

  authorize_resource

  def create
    if @card.save
      @resources << @comment
      render :create
    else
      render "errors/failed", status: 400
    end
  end

  def destroy
    if @comment.destroy
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

  def load_card
    if params[:note_card_id]
      @card = @project.note.note_cards.find params[:note_card_id]
      @resources = [@owner, @project, :note, @card]
    end
  end

  def build_comment
    comment = @card.comments.create
    comment_parameter = comment_params
    comment.body = comment_parameter[:body]
    comment.user_id = comment_parameter[:user_id]
    @comment = comment
  end

  def load_comment
    @comment = @card.comments.find params[:id]
  end

  def comment_params
    if params[:comment]
      params.require(:comment).permit Comment.updatable_columns
    end
  end
end