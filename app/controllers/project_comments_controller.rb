class ProjectCommentsController < ApplicationController
  def create
    project = Project.find(params[:project_id])
    project_comment = project.project_comments.build(project_comment_params)

    if project_comment.save
      notify_users(project)
      redirect_to project_path(project.owner, project, anchor: "project-comment-#{project_comment.id}")
    else
      redirect_to project_path(project.owner, project, anchor: "project-comment-form"),
                  alert: project_comment.errors.full_messages,
                  flash: { project_comment_body: project_comment.body }
    end
  end

  def destroy
    project_comment = ProjectComment.find(params[:id])
    project = project_comment.project

    unless project_comment.manageable_by?(current_user)
      redirect_to project_path(project.owner, project, anchor: "project-comments"),
                  alert: 'You can not delete a comment'
      return
    end

    if project_comment.destroy
      redirect_to project_path(project.owner, project, anchor: "project-comments")
    else
      redirect_to project_path(project.owner, project, anchor: "project-comments"),
                  alert: 'Comment could not be deleted'
    end
  end

  private

    def project_comment_params
      params.require(:project_comment).permit(:body).merge(user: current_user)
    end

    def notify_users(project)
      users = project.notifiable_users(current_user)
      return if users.blank?

      body = "#{current_user.name} commented on #{project.title}."
      project.notify(users, current_user, project_path(project.owner, project), body)
    end
end
