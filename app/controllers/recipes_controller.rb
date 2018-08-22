class RecipesController < ApplicationController
  def update
    project = Project.find_with(params[:owner_name], params[:project_id])

    if can?(:update, project) && project.update(recipe_params)
      project.touch
      render json: { success: true }
    else
      render json: { success: false }, status: 400
    end
  end

  private

    def recipe_params
      params.require(:recipe).permit(states_attributes: [:id, :position])
    end
end
