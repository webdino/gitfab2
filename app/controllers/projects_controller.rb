class ProjectsController < ApplicationController
  layout 'project'

  before_action :load_owner, except: [:new, :create, :fork]
  before_action :load_project, only: [:edit, :update, :destroy]
  before_action :delete_collaborations, only: :destroy

  authorize_resource

  def show
    @project = @owner.projects.includes(usages: [:attachments, :figures, :contributions, :project])
                     .friendly.find(params[:id])
    @recipe = @project.recipe
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
      redirect_to edit_project_path(id: @project, owner_name: @owner)
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

    @project.updated_at = DateTime.now.in_time_zone
    if @project.update parameters
      notify_users_on_update(@project, @owner)
      respond_to do |format|
        format.json { render json: { success: true } }
        format.html { redirect_to project_path(@project, owner_name: @owner) }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false }, status: 400 }
        format.html { render :edit, status: 400 }
      end
    end
  end

  def destroy
    if @project.soft_destroy
      redirect_to owner_path(owner_name: @project.owner.slug)
    else
      render 'error/failed', status: 400
    end
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
    @project = @owner.projects.friendly.find(params[:project_id])
    @recipe = @project.recipe
    render 'recipe_cards_list'
  end

  def relation_tree
    @project = @owner.projects.friendly.find(params[:project_id])
    @root = @project.root(@project)
    render 'relation_tree', format: 'json'
  end

  private

    def project_params
      if params[:project]
        params.require(:project).permit(Project.updatable_columns)
      end
    end

    def load_project
      @project = @owner.projects.friendly.find(params[:id])
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

      url = project_path(project, owner_name: owner)
      body = "#{project.title} was updated by #{current_user.name}."
      project.notify(users, current_user, url, body)
    end
end
