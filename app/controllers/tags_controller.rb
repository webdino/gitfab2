class TagsController < ApplicationController
  before_action :load_recipe
  before_action :load_tag, only: :destroy

  def create
    @recipe.tag_list.add tag_params[:name]
    @recipe.save
    @tag = @recipe.tags.find_by name: tag_params[:name]
  end

  def destroy
    @recipe.tag_list.remove @tag.name
    @recipe.save
  end

  private
  def tag_params
    params.require(:tag).permit Tag::UPDATABLE_COLUMNS
  end

  def load_tag
    @tag = @recipe.tags.find params[:id]
  end

  def load_recipe
    @recipe = Recipe.find params[:recipe_id]
  end
end
