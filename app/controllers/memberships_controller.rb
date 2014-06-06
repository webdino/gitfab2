class MembershipsController < ApplicationController
  before_action :load_user
  before_action :build_membership, only: :create
  before_action :load_membership, only: [:update, :destroy]

  def index
    render layout: "user"
  end

  def create
    if @membership.save
      render "create"
    else
      render "failed"
    end
  end

  def update
    if @membership.update membership_params
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
      params.require(:membership).permit Membership.updatable_columns
    end
  end

  def load_user
    @user = User.find params[:user_id]
  end

  def build_membership
    @membership = @user.memberships.build membership_params
  end
  
  def load_membership
    @membership = @user.memberships.find params[:id]
  end
end
