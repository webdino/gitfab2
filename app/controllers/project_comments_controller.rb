class ProjectCommentsController < ApplicationController
  def create
    project = Project.find(params[:project_id])
    project_comment = project.project_comments.build(project_comment_params)
    project_comment.user = current_user

    if project_comment.save
      notify_users(project)
      redirect_to project_path(project.owner.slug, project, anchor: "project-comment-#{project_comment.id}")
    else
      redirect_to project_path(project.owner.slug, project, anchor: "project-comment-form"),
                  alert: project_comment.errors.full_messages,
                  flash: { project_comment_body: project_comment.body }
    end
  end

  def destroy
    project_comment = ProjectComment.find(params[:id])
    project = project_comment.project

    unless project.manageable_by?(current_user)
      redirect_to project_path(project.owner.slug, project, anchor: "project-comments"),
                  alert: 'You can not delete a comment' and return
    end

    if project_comment.destroy
      redirect_to project_path(project.owner.slug, project, anchor: "project-comments")
    else
      redirect_to project_path(project.owner.slug, project, anchor: "project-comments"),
                  alert: 'Comment could not be deleted'
    end
  end

  private

    def project_comment_params
      params.require(:project_comment).permit(:body)
    end

    def notify_users(project)
      users = project.notifiable_users(current_user)
      return if users.blank?

      url = project_path(project, owner_name: project.owner.slug)
      body = "#{current_user.name} commented on #{project.title}."
      project.notify(users, current_user, url, body)
    end
end
