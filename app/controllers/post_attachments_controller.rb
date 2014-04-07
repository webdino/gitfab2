class PostAttachmentsController < ApplicationController
  before_action :load_user
  before_action :load_recipe

  def create
    post_attachment = @recipe.post_attachments.build content: params[:file]
    if post_attachment.save
      render json: {
        image: {
         url: post_attachment.content.figure.url
        }
      }, content_type: "text/html"
    else
      render json: {
        result: "failed to upload"
      }, content_type: "text/html"
    end
  end

  private
  def load_user
    @user = User.find params[:user_id]
  end

  def load_recipe
    @recipe = @user.recipes.find params[:recipe_id]
  end

end
