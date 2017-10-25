class UsersController < ApplicationController
  layout 'user'

  before_action :load_user, only: [:edit, :update, :destroy]
  before_action :verify_name, except: [:edit, :update]

  #  authorize_resource

  def index
    @users = User.order(:name) # TODO: ユーザー名による絞り込み
  end

  def edit
    @user = current_user
  end

  def update
    if @user.update user_params
      redirect_to [:edit, @user], notice: 'User profile was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to root_path
  end

  private

  def load_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    params.require(:user).permit(User.updatable_columns + additional_params)
  end

  def additional_params
    [:remove_avatar]
  end
end
