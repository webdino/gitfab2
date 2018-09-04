class GroupsController < ApplicationController
  layout 'groups'

  before_action :load_group, only: [:edit, :update, :destroy]
  before_action :forbidden, only: [:edit, :update, :destroy]

  def index
    @groups = current_user.groups
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
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
    if @group.update_attributes(group_params)
      redirect_to [:edit, @group], notice: 'Group profile was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    unless @group.deletable?
      redirect_to [:edit, @group], alert: 'This group still has projects.'
      return
    end

    @group.soft_destroy!
    redirect_to :groups
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotDestroyed
    redirect_to [:edit, @group], alert: 'Group was not deleted.'
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

    def load_group
      @group = current_user.groups.friendly.find params[:id]
    end

    def forbidden
      unless current_user.is_admin_of?(@group)
        render file: "public/403.html", status: :forbidden
      end
    end
end
