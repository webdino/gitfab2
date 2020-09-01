class ProjectsController < ApplicationController
  layout 'project'

  before_action :load_owner, except: [:index, :new, :create, :fork, :change_order, :search]
  before_action :load_project, only: [:edit, :update, :destroy, :destroy_or_render_edit]
  before_action :delete_collaborations, only: [:destroy, :destroy_or_render_edit]

  authorize_resource

  def index
    projects = Project.published.includes(:figures, :owner)
    @popular_projects = ProjectAccessStatistic.access_ranking.merge(projects).limit(10)
    @featured_groups = Group.access_ranking
    @recent_projects = projects.order(updated_at: :desc).limit(12)
  end

  def show
    @project = @owner.projects.active.includes(usages: [:attachments, :figures, :contributions, :project])
                     .friendly.find(params[:id])

    unless can?(:read, @project)
      render_404
      return
    end

    ProjectAccessLog.log!(@project, current_user)
    @project_comments = @project.project_comments.order(:id)
  end

  def new
    @project = current_user.projects.build
  end

  def create
    @owner = Owner.find_by(params[:project][:owner_id]) || current_user
    @project = @owner.projects.build(project_params)
    slug = project_params[:title].gsub(/\W|\s/, 'x').downcase
    @project.name = slug

    if @project.save
      redirect_to edit_project_path(@owner, @project)
    else
      render :new
    end
  end

  def edit
  end

  def update
    parameters = project_params
    if parameters.present? && parameters[:name].present?
      parameters[:name] = parameters[:name].downcase
    end

    if @project.update parameters
      notify_users_on_update(@project, @owner)
      respond_to do |format|
        format.json { render json: { success: true } }
        format.html { redirect_to project_path(@owner, @project) }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false }, status: 400 }
        format.html { render :edit, status: 400 }
      end
    end
  end

  def destroy
    @project.soft_destroy!
    redirect_to owner_path(@project.owner)
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordNotSaved
    redirect_to owner_path(@project.owner), flash: { alert: 'Project could not be deleted.' }
  end

  def destroy_or_render_edit
    @project.soft_destroy!
    redirect_to owner_path(@project.owner)
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordNotSaved
    flash.now[:alert] = 'Project could not be deleted.'
    render :edit
  end

  def fork
    target_owner = Owner.find(params[:owner_id])
    original_project = Project.find_with(params[:owner_name], params[:project_id])
    forked_project = original_project.fork_for!(target_owner)
    path = project_path(target_owner, forked_project)

    notifiable_users = original_project.notifiable_users(current_user)
    if notifiable_users.present?
      forked_project.notify(
        notifiable_users,
        current_user,
        path,
        "#{original_project.title} was forked by #{current_user.name}."
      )
    end

    redirect_to path
  end

  def recipe_cards_list
    @project = @owner.projects.active.friendly.find(params[:project_id])
    render 'recipe_cards_list'
  end

  def relation_tree
    @project = @owner.projects.friendly.find(params[:project_id])
    @root = @project.root
    render 'relation_tree', format: 'json'
  end

  def change_order
    project = Project.find_with(params[:owner_name], params[:project_id])
    parameters = params.require(:project).permit(states_attributes: [:id, :position])
    if can?(:update, project) && project.update(parameters)
      render json: { success: true }
    else
      render json: { success: false }, status: 400
    end
  end

  def search
    @projects = Project.published.includes(:figures, :owner)
    if params[:q].present?
      @query = params[:q].force_encoding('utf-8')
      @projects = @projects.search_draft(@query)
    end
    @projects = @projects.order(updated_at: :desc).page(params[:page])
  end

  def slideshow
    @project = @owner.projects.active.includes(states: [:figures, annotations: :figures])
                 .friendly.find(params[:project_id])
    @cards = @project.states.map { |state| [state] + state.annotations }.flatten
    render layout: nil
  end

  private

    def project_params
      if params[:project]
        params.require(:project).permit(Project.updatable_columns)
      end
    end

    def load_project
      @project = @owner.projects.active.friendly.find(params[:id] || params[:project_id])
    end

    def load_owner
      owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
      owner_id.downcase!
      @owner = Owner.find(owner_id)
    end

    def delete_collaborations
      @project.collaborators.each do |collaborator|
        collaboration = collaborator.collaborations.where('project_id' => @project.id).first
        collaboration.destroy
      end
    end

    def notify_users_on_update(project, owner)
      users = project.notifiable_users current_user
      return if users.blank?

      url = project_path(owner, project)
      body = "#{project.title} was updated by #{current_user.name}."
      project.notify(users, current_user, url, body)
    end
end
