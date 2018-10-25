class UsersController < ApplicationController
  layout 'user'

  def index
    @users = User.active.order(:name) # TODO: ユーザー名による絞り込み
  end

  def new
    @user =
      if params[:token].present?
        # OAuth Sign up
        identity = Identity.find_by_encrypted_id(params[:token])
        User.new(
          name: identity.nickname,
          email: identity.email,
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
        user_attrs = user_params.reverse_merge(remote_avatar_url: (identity.image unless user_params[:avatar_cache]))
        User.create_from_identity(identity, user_attrs)
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
    @user = User.find(current_user.id)
  end

  def update
    @user = User.find(current_user.id)
    if @user.update(user_params)
      redirect_to edit_user_path, flash: { success: 'User profile was successfully updated.' }
    else
      render action: 'edit'
    end
  end

  def destroy
    user = User.find(current_user.id)
    user.resign!
    self.current_user = nil
    redirect_to root_path, flash: { success: "退会しました。ご利用ありがとうございました。" }
  rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordNotDestroyed
    redirect_to edit_user_path, flash: { alert: 'Something went wrong. Please try again later.' }
  end

  def update_password
    user = User::PasswordAuth.find_by!(name: params[:user_id])

    if user.password_digest && !user.authenticate(params[:current_password])
      flash.now[:danger] = "現在のパスワードが間違っています"
      @user = User.find_by(name: params[:user_id])
      render :edit
      return
    end

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      flash[:success] = "パスワードを更新しました"
      redirect_to edit_user_path
    else
      flash.now[:danger] = "パスワードの更新に失敗しました"
      @update_password_error_messages = user.errors.full_messages
      @user = User.find_by(name: params[:user_id])
      render :edit
    end
  end

  def backup
    user = User.active.find_by(name: params[:user_id])
    if can?(:backup, user)
      BackupJob.perform_later(user)
      redirect_to edit_user_path, flash: { success: "バックアップを開始しました。バックアップファイルのダウンロードの準備ができ次第、メールでリンクをお送りします。" }
    else
      render_403
    end
  end

  def download_backup
    user = User.active.find_by(name: params[:user_id])
    if can?(:download_backup, user)
      backup = Backup.new(user)
      send_data(backup.path_to_zip.read, filename: backup.zip_filename)
    else
      render_403
    end
  end

  private

    def user_params
      params.require(:user).permit(
        :name, :email, :email_confirmation, :url, :location, :avatar, :avatar_cache,
        :password, :password_confirmation, :encrypted_identity_id
      )
    end
end
