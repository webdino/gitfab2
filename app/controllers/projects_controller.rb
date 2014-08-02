class ProjectsController < ApplicationController
  layout "project"

  before_action :load_owner
  before_action :load_project, only: [:show, :edit, :update, :destroy]
  before_action :build_project, only: [:new, :create]

  def index
    if q = params[:q]
      @projects = @owner.projects.solr_search do
        fulltext q.split.map{|word| "\"#{word}\""}.join " AND "
        case params[:type]
        when "own"
          with :owner_id, params[:user_id]
        when "contributed"
          # TODO: Implement
        when "starred"
          # TODO: Implement
        end
      end.results
    else
      @projects = Project.order "updated_at DESC"
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
    if @project.update project_params
      respond_to do |format|
        format.json {render :update}
        format.html {redirect_to project_path(@project, owner_name: @owner.slug)}
      end
    else
      respond_to do |format|
        format.json "error/failed", status: 400
        format.html :edit
      end
    end
  end

  private
  def project_params
    if params[:project]
      params.require(:project)
        .permit(Project.updatable_columns + [likes_attributes: [:_destroy, :id, :liker_id]])
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
