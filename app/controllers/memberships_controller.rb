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
    if @membership.deletable?
      @membership.destroy
    else
      render json: { success: false, message: 'You can not remove this member.' }
    end
  end
end
