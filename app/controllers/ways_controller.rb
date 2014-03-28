class WaysController < ItemsController
  after_action :add_contributor, [:create, :update, :destroy]

  def add_contributor
    unless @item.recipe.user == current_user
      @item.recipe.contributors << current_user
    end
  end
end
