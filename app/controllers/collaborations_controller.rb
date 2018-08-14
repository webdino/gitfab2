class CollaborationsController < ApplicationController
  before_action :load_owner
  before_action :load_collaboration, only: :destroy
  before_action :build_collaboration, only: :create

  authorize_resource

  def index
  end

  def create
    if @collaboration.save
      render :create
    else
      render json: { success: false }
    end
  end

  def destroy
    @collaboration.destroy
    render json: { success: true, id: @collaboration.id }
  end

  private

  def collaboration_params
    if params[:collaboration].present?
      params.require(:collaboration).permit [:project_id]
    end
  end

  def build_collaboration
    @collaboration = @owner.collaborations.build collaboration_params
  end

  def load_collaboration
    @collaboration = @owner.collaborations.find params[:id]
  end

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = Owner.find(owner_id)
  end
end
