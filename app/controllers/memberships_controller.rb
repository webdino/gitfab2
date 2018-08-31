class MembershipsController < ApplicationController
  def index
    @user = User.friendly.find params[:user_id]
    render layout: 'user'
  end

  def update
    membership = Membership.find(params[:id])
    if can?(:update, membership) && membership.update(params.require(:membership).permit(:role))
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  def destroy
    @user = User.friendly.find params[:user_id]
    @membership = @user.memberships.find params[:id]
    if @membership.group.members.length == 1 && @membership.group.projects.length > 0
      render json: { success: false, message: 'This group still has projects.' }
    else
      @membership.destroy
    end
  end
end
