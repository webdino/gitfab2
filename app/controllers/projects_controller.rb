class ProjectsController < ApplicationController
  layout "project"

  before_action :load_owner
  before_action :load_project, only: [:show, :update, :destroy]
  before_action :build_project, only: [:new, :create]

  def index
    render layout: "dashboard"
  end

  def show
    redirect_to project_recipe_path(project_id: @project.id, owner_name: @project.owner.name)
  end

  def new
  end

  def create
    return fork if params[:original_project_id]
    if @project.save
      redirect_to project_path(id: @project.name, owner_name: @owner.name)
    else
      render :new
    end
  end

  def fork
    original_project = Project.find params[:original_project_id]
    if (@project = original_project.fork_for @owner).save
      redirect_to project_path(id: @project.name, owner_name: @owner.name)
    else
      redirect_to request.referer
    end
  end

  def edit
  end

  def update
    if @project.update project_params
      respond_to do |format|
        format.json {render :update}
        format.html {redirect_to project_path(@project, owner_name: @owner.name)}
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
        .permit(Project.updatable_columns + [likes_attributes: [:_destroy]])
    end
  end

  def build_project
    @project = @owner.projects.build project_params
  end

  def load_project
    @project = @owner.projects.find params[:id]
  end

  def load_owner
    if params[:owner_name]
      @owner ||= User.find params[:owner_name]
      @owner ||= Group.find params[:owner_name]
    end
  end
end
