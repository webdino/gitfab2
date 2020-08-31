class LikesController < ApplicationController
  def show
    project = Project.find_with(params[:owner_name], params[:project_id])
    liked = project.likes.where(user: current_user).exists?
    render json: { success: true, like: { liked: liked } }
  end

  def create
    project = Project.find_with(params[:owner_name], params[:project_id])
    like = Like.find_or_initialize_by(project: project, user: current_user)
    render json: { success: like.persisted? || like.save }
  end

  def destroy
    project = Project.find_with(params[:owner_name], params[:project_id])
    like = Like.find_by(project: project, user: current_user)
    like&.destroy
    render json: { success: true }
  end
end
