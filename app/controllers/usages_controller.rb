class UsagesController < ApplicationController
  before_action :load_owner
  before_action :load_project
  before_action :build_usage, only: [:new, :create]
  before_action :load_usage, only: [:edit, :update, :destroy]
  before_action :update_contribution, only: [:create, :update]
  after_action :update_project, only: [:create, :update, :destroy]

  authorize_resource class: Card::Usage.name

  def new
  end

  def edit
  end

  def create
    if @usage.save
      @project.updated_at = DateTime.now.in_time_zone
      @project.save!
      render :create
    else
      render json: { success: false }, status: 400
    end
  end

  def update
    auto_linked_params = usage_params
    if @usage.update auto_linked_params
      @project.updated_at = DateTime.now.in_time_zone
      @project.save!
      render :update
    else
      render json: { success: false }, status: 400
    end
  end

  def destroy
    if @usage.destroy
      render json: { success: true }
    else
      render json: { success: false }, status: 400
    end
  end

  private

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = Owner.find(owner_id)
  end

  def load_project
    @project = @owner.projects.friendly.find params[:project_id]
    not_found if @project.blank?
  end

  def load_usage
    @usage = @project.usages.find params[:id]
    not_found if @usage.blank?
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
    return unless current_user
    @usage.contributions.each do |contribution|
      if contribution.contributor_id == current_user.id
        contribution.updated_at = DateTime.now.in_time_zone
        return
      end
    end
    contribution = @usage.contributions.new
    contribution.contributor_id = current_user.id
    contribution.created_at = DateTime.now.in_time_zone
    contribution.updated_at = DateTime.now.in_time_zone
  end

  def update_project
    if @_response.response_code == 200
      @project.updated_at = DateTime.now.in_time_zone
      @project.save!
    end
  end
end
