class AttachmentsController < ApplicationController
  before_action :load_owner
  before_action :load_recipe
  before_action :build_attachment, only: :create

  authorize_resource

  def create
    render (@attachment.save ? :create : :failed), content_type: "text/html"
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

  def build_attachment
    @attachment = @recipe.attachments.build content: params[:file],
      description: params[:alt]
  end
end
