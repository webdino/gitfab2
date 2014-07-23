class UsagesController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :build_usage, only: [:new, :create]
  before_action :load_usage, only: [:edit, :update, :destroy]
  before_action :update_contribution, only: [:create, :update]

  authorize_resource class: Card::Usage.name

  def new
  end

  def edit
  end

  def create
    if @usage.save
      render :create
    else
      render "errors/failed", status: 400
    end
  end

  def update
    if @usage.update usage_params
      render :update
    else
      render "errors/failed", status: 400
    end
  end

  def destroy
    if @usage.destroy
      render :destroy
    else
      render "errors/failed", status: 400
    end
  end

  private
  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = User.find(owner_id) || Group.find(owner_id)
  end

  def load_project
    @project = @owner.projects.find params[:project_id]
  end

  def load_usage
    @usage = @project.usages.find params[:id]
  end

  def build_usage
    @usage = @project.usages.build usage_params
  end

  def usage_params
    if params[:usage]
      params.require(:usage).permit Card::Usage.updatable_columns
    end
  end

  def update_contribution
    unless current_user
      return
    end
    @usage.contributions.each do |contribution|
      if contribution.contributor_id == current_user.slug
        contribution.updated_at = DateTime.now
        return
      end
    end
    contribution = @usage.contributions.new
    contribution.contributor_id = current_user.slug
    contribution.created_at = DateTime.now
    contribution.updated_at = DateTime.now
  end

end
