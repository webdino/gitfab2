class Admin::ProjectsController < Admin::ApplicationController
  before_action :load_project, only: [:show, :update, :destroy]

  def index
    @projects = Project.published
    @projects = @projects.ransack(draft_cont_all: params[:q].split(/\p{space}+/)).result if params[:q]
    @projects = @projects.page(params[:page])
  end

  def show; end

  def destroy
    @project.soft_destroy
    redirect_to admin_projects_path
  end

  private

  def load_project
    @project = Project.friendly.find(params[:id])
  end
end
