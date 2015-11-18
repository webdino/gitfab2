class CollaborationsController < ApplicationController
  before_action :load_owner
  before_action :load_collaboration, only: :destroy
  before_action :build_collaboration, only: :create
  before_action :delete_right, only: :destroy
  after_action :build_right, only: :create

  authorize_resource

  def index
  end

  def create
    if @collaboration.save
      render :create
    else
      render :failed
    end
  end

  def destroy
    @collaboration.destroy
    render :destroy
  end

  private

  def collaboration_params
    if params[:collaboration].present?
      params.require(:collaboration).permit [:project_id]
    end
  end

  def build_right
    right = Right.new right_holder_id: @collaboration.owner.id, right_holder_type: @collaboration.owner.class.name, project_id: @collaboration.project.id
    right.save
  end

  def delete_right
    right = Right.where('right_holder_id' => @collaboration.owner.id).where('project_id' => @collaboration.project.id)
    right.delete
  end

  def build_collaboration
    @collaboration = @owner.collaborations.build collaboration_params
  end

  def load_collaboration
    @collaboration = @owner.collaborations.find params[:id]
  end

  def load_owner
    owner_id = params[:owner_name] || params[:user_id] || params[:group_id]
    @owner = User.find(owner_id) || Group.find(owner_id)
  end
end
