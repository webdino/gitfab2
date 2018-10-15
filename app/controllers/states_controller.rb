class StatesController < ApplicationController
  before_action :load_owner
  before_action :load_project
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
      render json: { success: false }, status: 400
    end
  end

  def update
    if @state.update(state_params)
      render :update
    else
      render json: { success: false }, status: 400
    end
  end

  def destroy
    if @state.destroy
      render json: { success: true }
    else
      render json: { success: false }, status: 400
    end
  end

  def to_annotation
    state = @project.states.find(params[:state_id])
    parent_state = @project.states.find(params[:dst_state_id])
    annotation = state.to_annotation!(parent_state)
    render json: {'$oid' => annotation.id}
  end

  private

    def load_owner
      owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
      owner_id.downcase!
      @owner = Owner.find(owner_id)
    end

    def load_project
      @project = @owner.projects.active.friendly.find(params[:project_id])
    end

    def load_state
      @state ||= @project.states.find(params[:id])
    end

    def build_state
      @state = @project.states.build(state_params)
    end

    def state_params
      (params[:state] || ActionController::Parameters.new).permit Card::State.updatable_columns
    end

    def update_contribution
      return unless current_user
      @state.contributions.each do |contribution|
        if contribution.contributor_id == current_user.id
          contribution.updated_at = DateTime.now.in_time_zone
          return
        end
      end
      contribution = @state.contributions.new
      contribution.contributor_id = current_user.id
      contribution.created_at = DateTime.now.in_time_zone
      contribution.updated_at = DateTime.now.in_time_zone
    end

    def update_project
      return unless @_response.response_code == 200
      @project.touch

      users = @project.notifiable_users current_user
      url = project_path(@project.owner, @project)
      body = "#{current_user.name} updated the recipe of #{@project.title}."
      @project.notify users, current_user, url, body if users.length > 0
    end
end
