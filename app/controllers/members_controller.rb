class MembersController < ApplicationController
  def create
    @group = Group.find(params[:group_id])

    if can?(:manage, @group)
      user = User.friendly.find(params[:member_name])
      membership = user.join_to(@group)
      if membership
        @member = membership.user
        membership.role = params[:role]
        membership.save
        render :create
      else
        render json: { success: false }
      end
    else
      render json: { success: false }
    end
  end
end
