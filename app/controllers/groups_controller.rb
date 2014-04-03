class GroupsController < ApplicationController
  layout "dashboard"

  before_action :build_group, only: [:new, :create]
  before_action :load_group, only: [:show, :edit, :update, :destroy]

  def index
    @groups = Group.all
  end

  def show
  end

  def new
  end

  def create
    @group.creator = current_user
    if @group.save
      redirect_to @group
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @group.update_attributes group_params
      redirect_to @group
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to :groups
  end

  private
  def group_params
    if params[:group]
      params.require(:group).permit Group::UPDATABLE_COLUMNS
    end
  end

  def build_group
    @group = Group.new group_params
  end
  
  def load_group
    @group = Group.find params[:id]
  end
end
