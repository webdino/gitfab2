class UsersController < ApplicationController
  layout 'user'

  def index
    @users = User.order(:name) # TODO: ユーザー名による絞り込み
  end

  def new
    identity = Identity.find_by_encrypted_id(params[:token])
    @user = User.new(
      name: identity.nickname,
      fullname: identity.name,
      remote_avatar_url: identity.image,
      encrypted_identity_id: params[:token]
    )
    render :new, layout: "application"
  end

  def create
    identity = Identity.find_by_encrypted_id(user_params[:encrypted_identity_id])
    @user = User.new(
      user_params.reverse_merge({
        email: identity.email,
        fullname: identity.name,
        remote_avatar_url: (identity.image unless user_params[:avatar_cache])
      })
    )

    if @user.save
      @user.identities << identity
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

  private

    def user_params
      params.require(:user).permit(:name, :url, :location, :avatar, :avatar_cache, :encrypted_identity_id)
    end
end
