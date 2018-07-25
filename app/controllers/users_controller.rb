class UsersController < ApplicationController
  layout 'user'

  before_action :verify_name, except: [:edit, :update]

  def index
    @users = User.order(:name) # TODO: ユーザー名による絞り込み
  end

  def edit
    @user = User.friendly.find(params[:id])
  end

  def update
    @user = User.friendly.find(params[:id])
    if @user.update(user_params)
      redirect_to [:edit, @user], notice: 'User profile was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @user = User.friendly.find(params[:id])
    @user.destroy
    redirect_to root_path
  end

  private

    def user_params
      params.require(:user).permit(:avatar, :name, :url, :location, :remove_avatar)
    end
end
