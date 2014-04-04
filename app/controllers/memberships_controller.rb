class MembershipsController < ApplicationController
  before_action :load_group
  before_action :build_membership, only: :create
  before_action :load_membership, only: [:update, :destroy]

  def create
    if @membership.save
      render "create"
    else
      render "failed"
    end
  end

  def update
    if @membership.update_attributes membership_params
      render "update"
    else
      render "failed"
    end
  end

  def destroy
    @membership.destroy
  end

  private
  def membership_params
    if params[:membership]
      if user = User.where(slug: params[:membership][:user_id]).first
        params[:membership][:user_id] = user.id
      end
      params.require(:membership).permit Membership::UPDATABLE_COLUMNS
    end
  end

  def load_group
    @group = Group.find params[:group_id]
  end

  def build_membership
    @membership = @group.memberships.build membership_params
  end
  
  def load_membership
    @membership = @group.memberships.find params[:id]
  end
end
