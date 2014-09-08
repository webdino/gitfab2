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
    @project.updated_at = DateTime.now
    parameters = project_params
    if parameters.present? and parameters[:name].present?
      parameters[:name] = parameters[:name].downcase
    end
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
