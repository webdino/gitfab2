class NoteCardsController < ApplicationController
  layout 'project'

  before_action :load_owner
  before_action :load_project
  before_action :load_note_card, only: [:show, :edit, :update, :destroy]
  before_action :build_note_card, only: [:new, :create]
  before_action :update_contribution, only: [:create, :update]
  after_action :update_project, only: [:create, :update, :destroy]

  def index
    @note_cards = @project.note_cards
  end

  def new
  end

  def edit
  end

  def create
    @note_card.description = view_context.auto_link @note_card.description, html: { target: '_blank' }
    if @note_card.save
      render :create
    else
      render json: { success: false }, status: 400
    end
  end

  def show
  end

  def update
    auto_linked_params = note_card_params
    # titleのみを変更しようとした場合、descriptionは空になる
    # {"title"=>"_foo", "description"=>""}
    # validationをかけているので、ここで有無を判別する
    if note_card_params[:description].present?
      auto_linked_params[:description] = view_context.auto_link note_card_params[:description], html: { target: '_blank' }
    end
    if @note_card.update auto_linked_params
      render :update
    else
      render json: { success: false }, status: 400
    end
  end

  def destroy
    if @note_card.destroy
      render :destroy
    else
      render json: { success: false }, status: 400
    end
  end

  private

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = ProjectOwner.friendly_first(owner_id)
    not_found if @owner.blank?
  end

  def load_project
    @project = @owner.projects.friendly.find params[:project_id]
    not_found if @project.blank?
  end

  def load_note_card
    @note_card = @project.note_cards.find(params[:id])
    not_found if @note_card.blank?
  end

  def build_note_card
    @note_card = @project.note_cards.build(note_card_params)
  end

  def note_card_params
    if params[:note_card]
      params.require(:note_card).permit Card::NoteCard.updatable_columns
    end
  end

  def update_contribution
    return unless current_user
    @note_card.contributions.each do |contribution|
      if contribution.contributor_id == current_user.id
        contribution.updated_at = DateTime.now.in_time_zone
        return
      end
    end
    contribution = @note_card.contributions.new
    contribution.contributor_id = current_user.id
    contribution.created_at = DateTime.now.in_time_zone
    contribution.updated_at = DateTime.now.in_time_zone
  end

  def update_project
    return unless @_response.response_code == 200
    @project.updated_at = DateTime.now.in_time_zone
    @project.save!
    users = @project.notifiable_users current_user
    url = project_note_card_path owner_name: @project.owner.slug,
                                      project_id: @project.name,
                                      id: @note_card.id
    if action_name == 'update' && current_user
      body = "#{current_user.name} update a memo, '#{@note_card.title}' in #{@project.title}."
      @project.notify users, current_user, url, body if users.length > 0
    elsif action_name == 'create' && current_user
      body = "#{current_user.name} create a new memo, '#{@note_card.title}' in #{@project.title}."
      @project.notify users, current_user, url, body if users.length > 0
    end
  end
end
