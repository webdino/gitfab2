class StatesController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_recipe
  before_action :build_state, only: [:new, :create]
  before_action :load_state, only: [:edit, :show, :update, :destroy]
  before_action :update_contribution, only: [:create, :update]
  after_action :update_project, only: [:create, :update, :destroy]

  authorize_resource class: Card::State.name

  def new
  end

  def edit
  end

  def show
    render :show, formats: :json
  end

  def create
    if @state.save
      render :create
    else
      render 'errors/failed', status: 400
    end
  end

  def update
    if @state.update state_params
      render :update
    else
      render 'errors/failed', status: 400
    end
  end

  def destroy
    if @state.destroy
      render :destroy
    else
      render 'errors/failed', status: 400
    end
  end

  def to_annotation
    state = @recipe.states.find params[:state_id]
    not_found if state.blank?
    state._type = 'Card::Annotation'
    annotation = state.dup_document
    state.destroy
    dst_state = @recipe.states.find params[:dst_state_id]
    dst_state.annotations << annotation
    @recipe.states.each.with_index(1) do |st, index|
      st.position = index
      st.save
    end
    annotation.save
    render json: annotation.id
  end

  private

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    owner_id.downcase!
    @owner = User.find(owner_id) || Group.find(owner_id)
    not_found if @owner.blank?
  end

  def load_project
    @project = @owner.projects.find params[:project_id]
    not_found if @project.blank?
  end

  def load_recipe
    @recipe = @project.recipe
  end

  def load_state
    @state ||= @recipe.states.find(params[:id])
    not_found if @state.blank?
  end

  def build_state
    @state = @recipe.states.build state_params
  end

  def state_params
    if params[:state]
      params.require(:state).permit Card::State.updatable_columns
    end
  end

  def update_contribution
    return unless current_user
    @state.contributions.each do |contribution|
      if contribution.contributor_id == current_user.slug
        contribution.updated_at = DateTime.now.in_time_zone
        return
      end
    end
    contribution = @state.contributions.new
    contribution.contributor_id = current_user.slug
    contribution.created_at = DateTime.now.in_time_zone
    contribution.updated_at = DateTime.now.in_time_zone
  end

  def update_project
    return unless @_response.response_code == 200
    @project.updated_at = DateTime.now.in_time_zone
    @project.update

    users = @project.notifiable_users current_user
    url = project_path @project, owner_name: @project.owner.slug
    body = "#{current_user.name} updated the recipe of #{@project.title}."
    @project.notify users, current_user, url, body if users.length > 0
  end
end
