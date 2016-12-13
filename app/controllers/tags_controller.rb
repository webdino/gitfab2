class TagsController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :build_tag, only: :create
  before_action :load_tag, only: :destroy

  authorize_resource

  def create
    if @tag.save
      @resources = [@owner, @project, @tag]
      render :create
    else
      render 'errors/failed', status: 400
    end
  end

  def destroy
    if @tag.destroy
      render :destroy
    else
      render 'errors/failed', status: 400
    end
  end

  private

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = User.find_by_slug(owner_id) || Group.find_by_slug(owner_id)
  end

  def load_project
    @project = @owner.projects.friendly.find params[:project_id]
  end

  def build_tag
    tag = @project.tags.build
    tag_parameter = tag_params
    tag.name = Sanitize.clean(tag_parameter[:name]).strip
    tag.user = current_user
    @tag = tag
  end

  def load_tag
    @tag = @project.tags.find params[:id]
  end

  def tag_params
    params.require(:tag).permit Tag.updatable_columns if params[:tag]
  end
end
