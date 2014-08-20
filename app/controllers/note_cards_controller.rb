class NoteCardsController < ApplicationController
  layout "project"

  before_action :load_owner
  before_action :load_project
  before_action :load_note
  before_action :load_note_card, only: [:show, :edit, :update, :destroy]
  before_action :build_note_card, only: [:new, :create]
  before_action :update_contribution, only: [:create, :update]
  after_action :update_project, only: [:create, :update, :destroy]

  def new
  end

  def edit
  end

  def create
    if @note_card.save
      render :create
    else
      render "errors/failed", status: 400
    end
  end

  def show
  end

  def update
    if @note_card.update note_card_params
      render :update
    else
      render "errors/failed", status: 400
    end
  end

  def destroy
    if @note_card.destroy
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

  def load_note
    @note = @project.note
  end

  def load_note_card
    @note_card = @note.note_cards.find params[:id]
  end

  def build_note_card
    @note_card = @note.note_cards.build note_card_params
  end

  def note_card_params
    if params[:note_card]
      params.require(:note_card).permit Card::NoteCard.updatable_columns
    end
  end

  def update_contribution
    unless current_user
      return
    end
    @note_card.contributions.each do |contribution|
      if contribution.contributor_id == current_user.slug
        contribution.updated_at = DateTime.now
        return
      end
    end
    contribution = @note_card.contributions.new
    contribution.contributor_id = current_user.slug
    contribution.created_at = DateTime.now
    contribution.updated_at = DateTime.now
  end

  def update_project
    if @_response.response_code == 200
      @project.updated_at = DateTime.now
      @project.update
    end
  end
end
