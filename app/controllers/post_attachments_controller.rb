class PostAttachmentsController < ApplicationController
  before_action :load_owner
  before_action :load_recipe

  authorize_resource

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
  def load_owner
    owner_name = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = if User.exists? owner_name
      User.find owner_name
    elsif Group.exists? owner_name
      Group.find owner_name
    end
  end

  def load_recipe
    @recipe = @owner.recipes.find params[:recipe_id]
  end

end
