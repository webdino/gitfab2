class CollaborationsController < ApplicationController
  def create
    collaborator = Owner.find_by(params[:collaborator_name])
    unless collaborator
      render json: { success: false }, status: 400
      return
    end

    project = Owner.find(params[:owner_name]).projects.friendly.find(params[:project_id])
    @collaboration = collaborator.collaborations.build(project: project)
    if @collaboration.save
      notify_users(project, collaborator)
      render :create
    else
      render json: { success: false }, status: 400
    end
  end

  def destroy
    collaboration = Collaboration.find(params[:id])
    if can?(:destroy, collaboration) && collaboration.destroy
      render json: { success: true, id: collaboration.id }
    else
      render json: { success: false }, status: :bad_request
    end
  end

  private

    def collaboration_params
      params.require(:collaboration).permit(:project_id)
    end

    def notify_users(project, collaborator)
      users = project.notifiable_users(current_user)
      return if users.blank?

      project.notify(
        users, current_user,
        project_path(project.owner, project),
        "#{collaborator.name} was added as a collaborator of #{project.title}."
      )
    end
end
