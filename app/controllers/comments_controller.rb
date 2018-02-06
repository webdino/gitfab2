class CommentsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_card
  before_action :build_comment, only: :create
  before_action :load_comment, only: :destroy
  after_action :notify_users, only: :create

  authorize_resource

  def create
    if @card.save
      @resources << @comment
      render :create, locals: { card_order: @card.comments.length - 1 }
    else
      @message = @comment.errors.messages || { "Error:": "Something's wrong" }
      render 'failed', message: @message, status: 400
    end
  end

  def destroy
    if @comment.destroy
      render :destroy
    else
      render 'errors/failed', status: 400
    end
  end

  def notify_users
    users = @project.notifiable_users current_user
    if @card.class.name == 'Card::NoteCard'
      url = project_note_note_card_path owner_name: @project.owner.slug, project_id: @project.name, id: @card.id
      body = "#{current_user.name} commented on your memo of #{@project.title}."
    else
      url = project_path @project, owner_name: @project.owner.slug
      body = "#{current_user.name} commented on your recipe of #{@project.title}."
    end
    @project.notify users, current_user, url, body if users.length > 0
  end

  private

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = ProjectOwner.friendly_first(owner_id)
  end

  def load_project
    @project = @owner.projects.friendly.find params[:project_id]
  end

  def load_card
    if params[:note_card_id]
      @card = @project.note.note_cards.find params[:note_card_id]
      @resources = [@owner, @project, :note, @card]
    elsif params[:annotation_id]
      @state = @project.recipe.states.find params[:state_id]
      @card = @state.annotations.find params[:annotation_id]
      @resources = [@owner, @project, :recipe, @state, @card]
    elsif params[:state_id]
      @card = @project.recipe.states.find params[:state_id]
      @resources = [@owner, @project, :recipe, @card]
    end
  end

  def build_comment
    comment = @card.comments.build
    comment_parameter = comment_params
    comment.body = comment_parameter[:body]
    comment.user = current_user
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
