class WaysController < ItemsController
  private
  def set_parent
    @parent = @recipe.statuses.find params[:status_id]
  end
end
