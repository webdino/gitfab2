class CollaboratorsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :load_collaborator, only: :create
  before_action :build_collaboration, only: :create

  def index
  end

  def create
    if @collaboration.save
      notify_users
      render :create
    else
      render 'errors/failed', status: 400
    end
  end

  def notify_users
    users = @project.notifiable_users current_user
    url = project_path owner_name: @project.owner.slug, id: @project.name
    body = "#{@collaborator.name} was added as a collaborator of your project #{@project.title}."
    @project.notify users, current_user, url, body if users.length > 0
  end

  private

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = ProjectOwner.friendly_first(owner_id)
  end

  def load_project
    @project = @owner.projects.friendly.find params[:project_id]
  end

  def load_collaborator
    collaborator_id = params[:collaborator_name]
    @collaborator = ProjectOwner.friendly_first(collaborator_id)
  end

  def build_collaboration
    @collaboration = @collaborator.collaborations.build project_id: @project.id
  end
end
