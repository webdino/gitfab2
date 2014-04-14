class WaysController < ItemsController
  authorize_resource :way

  after_action :add_contributor, only: [:create, :update, :destroy]

  private
  def add_contributor
    unless @way.recipe.user == current_user
      @way.recipe.contributors << current_user
    end
  end
end
