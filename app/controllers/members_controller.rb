class MembersController < ApplicationController
  before_action :load_group
  before_action :load_user

  def create
    if membership = @user.join_to(@group)
      @member = membership.user
      render :create
    else
      render "errors/failed"
    end
  end

  private
  def member_params
    if params[:member]
      params.require(:member).permit [:name]
    end
  end

  def load_group
    @group = Group.find params[:group_id]
  end

  def load_user
    @user = User.find params[:member][:name]
  end
end
