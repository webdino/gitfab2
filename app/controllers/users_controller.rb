class UsersController < ApplicationController
  layout 'user'

  def index
    @users = User.order(:name) # TODO: ユーザー名による絞り込み
  end

  def new
    @user =
      if params[:token].present?
        # OAuth Sign up
        identity = Identity.find_by_encrypted_id(params[:token])
        User.new(
          name: identity.nickname,
          fullname: identity.name,
          remote_avatar_url: identity.image,
          encrypted_identity_id: params[:token]
        )
      else
        # Name/Password Sign up
        User::PasswordAuth.new
      end
    render :new, layout: "application"
  end

  def create
    @user =
      if user_params[:encrypted_identity_id].present?
        identity = Identity.find_by_encrypted_id(user_params[:encrypted_identity_id])
        User.create_from_identity(
          identity,
          user_params.reverse_merge(
            email: identity.email,
            fullname: identity.name,
            remote_avatar_url: (identity.image unless user_params[:avatar_cache])
          )
        )
      else
        User::PasswordAuth.create(user_params)
      end

    if @user.errors.blank?
      self.current_user = @user
      redirect_to root_path
    else
      render :new, layout: "application"
    end
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

  def update_password
    user = User::PasswordAuth.find_by!(name: params[:user_id])

    if user.password_digest && !user.authenticate(params[:current_password])
      flash.now[:alert] = "現在のパスワードが間違っています"
      @user = User.find_by(name: params[:user_id])
      render :edit
      return
    end

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      flash[:success] = "パスワードを更新しました"
      redirect_to edit_user_path(id: user.name)
    else
      flash.now[:alert] = "パスワードの更新に失敗しました"
      @update_password_error_messages = user.errors.full_messages
      @user = User.find_by(name: params[:user_id])
      render :edit
    end
  end

  private

    def user_params
      params.require(:user).permit(
        :name, :url, :location, :avatar, :avatar_cache,
        :password, :password_confirmation, :encrypted_identity_id
      )
    end
end
