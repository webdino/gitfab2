class Admin::ProjectsController < ApplicationController
  include Administration
  layout 'dashboard'

  before_action :load_project, only: [:show, :update, :destroy]

  def index
    q = params[:q].to_s
    @projects = Project.published.search { |s|
      s.fulltext q.split.map { |word| "\"#{word}\"" }.join ' AND '
      s.with(:is_deleted, false)
      s.paginate page: params[:page]
    }.results
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
