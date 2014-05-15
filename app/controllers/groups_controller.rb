class GroupsController < ApplicationController
  layout "groups"

  before_action :build_group, only: [:new, :create]
  before_action :load_group, only: [:show, :edit, :update, :destroy]

  authorize_resource

  def index
    @groups = Group.all
  end

  def show
  end

  def new
  end

  def create
    @group = Group.new group_params
    if @group.save
      @group.add_admin current_user
      redirect_to [:edit, @group]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @group.update_attributes group_params
      redirect_to [:edit, @group], notice: "Group profile was successfully updated."
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
      params.require(:group).permit Group::UPDATABLE_COLUMNS + additional_params
    end
  end

  def additional_params
    [:id, member_ids: []]
  end

  def build_group
    @group = Group.new group_params
  end

  def load_group
    @group = Group.find params[:id]
  end
end
