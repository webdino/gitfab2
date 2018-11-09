class SessionsController < ApplicationController
  class SignInForm
    include ActiveModel::Model
    attr_accessor :name, :password
  end

  def index
    if current_user
      redirect_to root_path
      return
    end

    @form = SignInForm.new
  end

  def create
    auth = request.env["omniauth.auth"]
    if auth
      # OAuth sign in
      identity = Identity.find_or_create_with_omniauth(auth)

      if current_user
        # 既存ユーザーへのIdentity追加
        if identity.user && identity.user != current_user
          # 他のユーザーのidentityの場合は、アクセス不能なユーザーが作られないように連携しない
          flash[:danger] = "This account is connected with another user"
        else
          if identity.update(user: current_user)
            flash[:success] = "Successfully signed in to #{auth.provider}!"
          else
            flash[:danger] = "Something went wrong. Please try again later"
          end
        end
        redirect_to edit_user_path
      elsif identity.user
        # ログイン
        self.current_user = identity.user
        redirect_to session[:previous_url] || root_path
      else
        # 新規ユーザー登録
        redirect_to new_user_path(token: identity.encrypted_id)
      end
    else
      # Password sign in
      user = User::PasswordAuth.active.find_by(name: sign_in_params[:name])
      if user&.password_digest && user&.authenticate(sign_in_params[:password])
        self.current_user = user
        redirect_to session[:previous_url] || root_path
      else
        @form = SignInForm.new(sign_in_params)
        flash.now[:danger] = "Your name or password is incorrect"
        render :index
      end
    end
  end

  def destroy
    self.current_user = nil
    redirect_to root_path
  end

  private

    def sign_in_params
      params.require(:sign_in).permit(:name, :password)
    end
end
