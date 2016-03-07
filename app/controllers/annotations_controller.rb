class AnnotationsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_recipe
  before_action :load_state
  before_action :load_annotation, only: [:edit, :show, :update, :destroy]
  before_action :build_annotation, only: [:new, :create]
  before_action :update_contribution, only: [:create, :update]
  after_action :update_project, only: [:create, :update, :destroy]

  authorize_resource class: Card::Annotation.name

  def new
  end

  def edit
  end

  def show
    render :show, formats: :json
  end

  def create
    if @annotation.save
      render :create
    else
      render 'errors/failed', status: 400
    end
  end

  def update
    auto_linked_params = annotation_params
    if @annotation.update auto_linked_params
      render :update
    else
      render 'errors/failed', status: 400
    end
  end

  def destroy
    if @annotation.destroy
      render :destroy
    else
      render 'errors/failed', status: 400
    end
  end

  def to_state
    annotation = @state.annotations.where(id: params[:annotation_id]).first
    if annotation.blank?
      render_404
    else
      annotation._type = 'Card::State'
      state = annotation.dup_document
      annotation.destroy
      @recipe.states << state
      @recipe.states.each.with_index(1) do |st, index|
        st.position = index
        st.save
      end
      @recipe.save
      render json: state.id
    end
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
    if params['state_id']
      @state = @recipe.states.find params['state_id']
      not_found if @state.blank?
    end
  end

  def load_annotation
    @annotation ||= @state.annotations.find params[:id]
    not_found if @annotation.blank?
  end

  def build_annotation
    @annotation = @state.annotations.build annotation_params
  end

  def annotation_params
    if params[:annotation]
      params.require(:annotation).permit Card::Annotation.updatable_columns
    end
  end

  def save_current_users_contribution
    return @annotation.contributions.find_all{|contribution|
      contribution.contributor_id == current_user.id
    }.map{|contribution|
      contribution.updated_at = DateTime.now.in_time_zone
      contribution
    }[0]
  end

  def create_new_contribution
    contribution = @annotation.contributions.new
    contribution.contributor_id = current_user.id
    contribution.created_at = DateTime.now.in_time_zone
    contribution.updated_at = DateTime.now.in_time_zone
    return contribution
  end

  def update_contribution
    return nil unless current_user
    return save_current_users_contribution || create_new_contribution
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
