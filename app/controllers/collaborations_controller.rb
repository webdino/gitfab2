class CollaborationsController < ApplicationController

  before_action :load_user
  before_action :load_collaboration, only: :destroy
  before_action :build_collaboration, only: :create

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

  def build_collaboration
    @collaboration = @user.collaborations.build collaboration_params
  end

  def load_collaboration
    @collaboration = @user.collaborations.find params[:id]
  end

  def load_user
    @user = User.find params[:user_id]
  end
end
