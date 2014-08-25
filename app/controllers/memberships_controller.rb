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
      @message = "create error"
      render "failed"
    end
  end

  def update
    if @membership.update membership_params
      render "update"
    else
      @message = "update error"
      render "failed"
    end
  end

  def destroy
    if @membership.group.members.length == 1 and @membership.group.projects.length > 0
      @message = "This group still has projects."
      render "failed" 
    else 
      @membership.destroy
    end
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
