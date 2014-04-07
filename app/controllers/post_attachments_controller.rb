class PostAttachmentsController < ApplicationController
  before_action :load_user
  before_action :load_recipe
  before_action :load_post, only: [:create]

  def create
    post_attachment = @post.post_attachments.build content: params[:file]
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

  def load_post
    @post = @recipe.posts.find params[:post_id]
  end

end
