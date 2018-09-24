class GroupsController < ApplicationController
  layout 'groups'

  def index
    @groups = current_user.groups.active
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
    redirect_to edit_group_path(@group)
  rescue ActiveRecord::ActiveRecordError
    render :new
  end

  def edit
    @group = load_group
    unless can?(:edit, @group)
      render_forbidden
    end
  end

  def update
    @group = load_group
    if can?(:update, @group)
      if @group.update_attributes(group_params)
        redirect_to edit_group_path(@group), notice: 'Group profile was successfully updated.'
      else
        render :edit
      end
    else
      render_forbidden
    end
  end

  def destroy
    group = load_group
    if can?(:destroy, group)
      begin
        group.soft_destroy!
        redirect_to :groups
      rescue ActiveRecord::RecordNotSaved
        redirect_to edit_group_path(group), alert: 'Group was not deleted.'
      end
    else
      render_forbidden
    end
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
      current_user.groups.active.friendly.find params[:id]
    end

    def render_forbidden
      render file: "public/403.html", status: :forbidden
    end
end
