class CollaboratorsController < ApplicationController
  before_action :load_owner
  before_action :load_project

  def index
  end

  def create
    collaborator_id = params[:collaborator_name]
    @collaborator = ProjectOwner.friendly_first(collaborator_id)
    unless @collaborator
      render json: { success: false }, status: 400
      return
    end

    @collaboration = @collaborator.collaborations.build(project_id: @project.id)
    if @collaboration.save
      notify_users(@project, @collaborator)
      render :create
    else
      render json: { success: false }, status: 400
    end
  end

  private

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = ProjectOwner.friendly_first(owner_id)
  end

  def load_project
    @project = @owner.projects.friendly.find params[:project_id]
  end

  def notify_users(project, collaborator)
    users = project.notifiable_users(current_user)
    return if users.blank?

    url = project_path(owner_name: project.owner.slug, id: project.name)
    body = "#{collaborator.name} was added as a collaborator of your project #{project.title}."
    project.notify(users, current_user, url, body)
  end
end
