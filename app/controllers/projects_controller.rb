class ProjectsController < ApplicationController
  layout "project"

  before_action :load_owner
  before_action :load_project, only: [:show, :edit, :update, :destroy]
  before_action :build_project, only: [:new, :create]

  authorize_resource

  def index
    if q = params[:q]
      owner_id = @owner.id
      @projects = Project.solr_search do |s|
        s.fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
        case params[:type]
        when "own"
          s.with :owner_id, owner_id
        when "contributed"
          # TODO: Implement
        when "starred"
          # TODO: Implement
        end
      end.results
    else
      @projects = @owner.projects.order "updated_at DESC"
    end
    render layout: "dashboard"
  end

  def show
    @recipe = @project.recipe
    render "recipes/show"
  end

  def new
  end

  def create
    return fork if params[:original_project_id]
    slug = project_params[:title]
    slug = slug.gsub(/\W|\s/,"x").downcase
    @project.name = slug
    if @project.save
      render :edit
    else
      render :new
    end
  end

  def fork
    original_project = Project.find params[:original_project_id]
    if @project = original_project.fork_for!(@owner)
      redirect_to project_path(id: @project.name, owner_name: @owner.slug)
    else
      redirect_to request.referer
    end
  end

  def destroy
    @project.destroy project_params
    redirect_to projects_path(owner_name: @project.owner.slug)
  end

  def edit
  end

  def update
    owner_name = params[:owner_name]
    if owner_name.present?
      self.change_owner
    else

      parameters = project_params
      if parameters.present? and parameters[:name].present?
        parameters[:name] = parameters[:name].downcase
      end

      if project_params[:likes_attributes].present?
        if @project.timeless.update parameters
          @project.clear_timeless_option
          respond_to do |format|
            format.json {render :update}
            format.html {redirect_to project_path(@project, owner_name: @owner.slug)}
          end
        else
          respond_to do |format|
            format.json {render "error/failed", status: 400}
            format.html {render :edit, status: 400}
          end
        end
      else
        @project.updated_at = DateTime.now
        if @project.update parameters
          respond_to do |format|
            format.json {render :update}
            format.html {redirect_to project_path(@project, owner_name: @owner.slug)}
          end
        else
          respond_to do |format|
            format.json {render "error/failed", status: 400}
            format.html {render :edit, status: 400}
          end
        end
      end
    end
  end

  def change_owner
    project = Project.find params[:id]
    new_owner = User.find(params[:owner_name]) || Group.find(params[:owner_name])
    if project.change_owner! new_owner
      if project.collaborators.include?(new_owner)
        old_collaboration = new_owner.collaboration_in project
        old_collaboration.destroy
      end
      new_owner_projects_path = "http://" + request.raw_host_with_port + "/" + new_owner.slug
      respond_to do |format|
        format.html {redirect_to projects_path(new_owner.slug)}
        format.js {render :js => "window.location.replace('" + new_owner_projects_path +"')"}
      end
    else
      respond_to do |format|
        format.json {render "error/failed", status: 400}
        format.html {render "error/failed", status: 400}
      end
    end
  end

  def potential_owners
    @project = @owner.projects.find params[:project_id]
    render "potential_owners", format: "json"
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
    @project = @owner.projects.find params[:id]
  end

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = User.find(owner_id) || Group.find(owner_id)
  end

end
