class TagsController < ApplicationController
  def create
    project = Project.find_with(params[:owner_name], params[:project_id])
    @tag = project.tags.build(tag_params)
    if can?(:create, @tag) && @tag.save
      project.update_draft!
      render :create
    else
      render json: { success: false }, status: 400
    end
  end

  def destroy
    tag = Tag.find(params[:id])
    if can?(:destroy, tag) && tag.destroy
      tag.project.update_draft!
      render json: { success: true }
    else
      render json: { success: false }, status: 400
    end
  end

  private

    def tag_params
      parameters = params.require(:tag).permit(:name)
      parameters[:name] = Sanitize.clean(parameters[:name]).strip
      parameters[:user] = current_user
      parameters
    end
end
