class UsersController < ApplicationController
  before_action :load_user, only: [:show, :edit, :update, :destroy]
  before_action :verify_name, except: [:edit, :update]

  authorize_resource

  def index
    @users = User.all
  end

  def show
  end

  def edit
    @user = current_user
  end

  def update
    if @user.update user_params
      redirect_to [:edit, current_user], notice: "User was successfully updated."
    else
      render action: "edit"
    end
  end

  def destroy
    @user.destroy
    redirect_to @user
  end

  private
  def load_user
    @user = User.find params[:id]
  end

  def user_params
    params.require(:user).permit (User::UPDATABLE_COLUMNS + additional_params)
  end

  def additional_params
    [:remove_avatar]
  end
end
