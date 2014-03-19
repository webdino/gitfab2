class UsersController < ApplicationController
  before_action :set_user, only: :show
  before_action :verify_name, except: [:edit, :update]

  def index
    @users = User.all
  end

  def show
  end

  def edit
  end

  def update
    if current_user.update user_params
      redirect_to current_user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    current_user.destroy
    redirect_to users_url
  end

  private
  def set_user
    current_user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit (User::UPDATABLE_COLUMNS + additional_params)
  end

  def additional_params
    [:remove_avatar]
  end
end
