class MembersController < ApplicationController
  before_action :load_group
  before_action :load_user

  def create
    membership = @user.join_to(@group)
    if membership
      @member = membership.user
      membership.role = params[:role]
      membership.save
      render :create
    else
      render 'errors/failed'
    end
  end

  private

  def member_params
    params.require(:member).permit [:name] if params[:member]
  end

  def load_group
    @group = Group.find params[:group_id]
  end

  def load_user
    @user = User.find params[:member_name]
  end
end
