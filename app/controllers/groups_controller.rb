class GroupsController < ApplicationController
  layout 'groups'

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
    Group.transaction do
      @group.save!
      membership = current_user.join_to @group
      membership.role = 'admin'
      membership.save!
    end
    redirect_to edit_group_url(@group)
  rescue ActiveRecord::ActiveRecordError
    render :new
  end

  def edit
  end

  def update
    if @group.update_attributes group_params
      redirect_to [:edit, @group], notice: 'Group profile was successfully updated.'
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
      not_found if @group.blank?
    end

    def load_group
      @group = Group.friendly.find params[:id]
    end
end
