class TagsController < ApplicationController
  before_action :load_recipe

  def create
    @tag = Tag.find_or_create_by name: tag_params[:name]
    @recipe.tags << @tag
  end

  def destroy
    @tag = Tag.find params[:id]
    @recipe.tags.destroy @tag
  end

  private
  def tag_params
    params.require(:tag).permit Tag::UPDATABLE_COLUMNS
  end

  def load_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
