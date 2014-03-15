class TagsController < ApplicationController
  def create
    @tag = Tag.find_or_create_by name: tag_params[:name]
  end

  private
  def tag_params
    params.require(:tag).permit Tag::UPDATABLE_COLUMNS
  end
end
