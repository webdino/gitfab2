class ProjectsController < ApplicationController
  layout 'project'

  before_action :load_owner
  before_action :load_project, only: [:show, :edit, :update, :destroy]
  before_action :build_project, only: [:new, :create]
  before_action :delete_collaborations, only: :destroy
  after_action :notify_users, only: [:create, :update]

  authorize_resource

  def index
    @projects = @owner.projects.order 'updated_at DESC'
    render layout: 'dashboard'
  end

  def show
    @recipe = @project.recipe
    render 'recipes/show'
  end

  def new
  end

  def create
    return fork if params[:original_project_id]
    slug = project_params[:title]
    slug = slug.gsub(/\W|\s/, 'x').downcase
    @project.name = slug
    if @project.save
      redirect_to edit_project_url(id: @project, owner_name: @owner)
    else
      render :new
    end
  end

  def fork
    original_project = Project.find params[:original_project_id]
    @project = original_project.fork_for! @owner
    if original_project.present? && @project.present?
      redirect_to project_path(id: @project, owner_name: @owner)
    else
      redirect_to request.referer
    end
  end

  def destroy
    if @project.soft_destroy
      redirect_to projects_path(owner_name: @project.owner)
    else
      render 'error/failed', status: 400
    end
  end

  def edit
  end

  def update
    new_owner_name = params[:new_owner_name]
    if new_owner_name.present?
      change_owner
    else

      parameters = project_params
      if parameters.present? && parameters[:name].present?
        parameters[:name] = parameters[:name].downcase
      end

      if project_params[:likes_attributes].present?
        likes_attributes = project_params[:likes_attributes]
        if @project.update(likes_attributes: likes_attributes)
          respond_to do |format|
            format.json { render :update }
            format.html { redirect_to project_path(@project, owner_name: @owner) }
          end
        else
          @project.clear_timeless_option
          respond_to do |format|
            format.json { render 'error/failed', status: 400 }
            format.html { render :edit, status: 400 }
          end
        end
      else
        @project.updated_at = DateTime.now.in_time_zone
        if @project.update parameters
          respond_to do |format|
            format.json { render :update }
            format.html { redirect_to project_path(@project, owner_name: @owner) }
          end
        else
          respond_to do |format|
            format.json { render 'error/failed', status: 400 }
            format.html { render :edit, status: 400 }
          end
        end
      end
    end
  end

  def change_owner
    project = Project.find params[:id]
    new_owner = User.find(params[:new_owner_name]) || Group.find(params[:new_owner_name])
    if new_owner.present? && project.change_owner!(new_owner)
      if project.collaborators.include?(new_owner)
        old_collaboration = new_owner.collaboration_in project
        old_collaboration.destroy
      end
      new_owner_projects_path = 'https://' + request.raw_host_with_port + '/' + new_owner.slug
      respond_to do |format|
        format.html { redirect_to projects_path(new_owner.slug) }
        format.js { render js: "window.location.replace('" + new_owner_projects_path + "')" }
      end
    else
      render 'error/failed', status: 400
    end
  end

  def potential_owners
    @project = @owner.projects.friendly.find params[:project_id]
    render 'potential_owners', format: 'json'
  end

  def recipe_cards_list
    @project = @owner.projects.friendly.find params[:project_id]
    @recipe = @project.recipe
    render 'recipe_cards_list'
  end

  def relation_tree
    @project = @owner.projects.friendly.find params[:project_id]
    @root = @project.root(@project)
    render 'relation_tree', format: 'json'
  end

  def notify_users
    if action_name == 'update'
      users = @project.notifiable_users current_user
      url = project_path @project, owner_name: @owner
      if params[:new_owner_name]
        return
      elsif project_params[:likes_attributes].present?
        body = "#{@project.title} was favorited by #{current_user.name}."
      else
        body = "#{@project.title} was updated by #{current_user.name}."
      end
      @project.notify users, current_user, url, body if users.length > 0
    elsif action_name == 'create' && params[:original_project_id]
      original_project = Project.find params[:original_project_id]
      users = @project.notifiable_users current_user, original_project
      url = project_path @project, owner_name: @owner
      body = "#{original_project.title} was forked by #{current_user.name}."
      @project.notify users, current_user, url, body if users.length > 0
    end
  end

  private

  def project_params
    if params[:project]
      params.require(:project).permit(Project.updatable_columns)
    end
  end

  def build_project
    @project = @owner.projects.build project_params
  end

  def load_project
    @project = @owner.projects.friendly.find params[:id]
    not_found if @project.blank?
  end

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    # FIXME: :user_id, :group_idが数値の文字列で渡された場合
    # owner_id.downcase! はnilになってしまうのでは
    owner_id.downcase!
    # friendly_firstは内部的にfind_by_slugを使用している
    # owner_idという名前もどうなんだろな
    @owner = ProjectOwner.friendly_first(owner_id)
    not_found if @owner.blank?
  end

  def delete_collaborations
    @project.collaborators.each do |collaborator|
      collaboration = collaborator.collaborations.where('project_id' => @project.id).first
      collaboration.destroy
    end
  end
end
