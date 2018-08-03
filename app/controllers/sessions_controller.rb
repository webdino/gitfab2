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
    if current_user
      redirect_to root_path
      return
    end

    auth = request.env["omniauth.auth"]
    if auth
      # OAuth sign in
      identity = Identity.find_or_create_with_omniauth(auth)
      if identity.user
        self.current_user = identity.user
        redirect_to session[:previous_url] || root_path
      else
        redirect_to new_user_path(token: identity.encrypted_id)
      end
    else
      # Password sign in
      user = User::PasswordAuth.find_by(name: sign_in_params[:name])&.authenticate(sign_in_params[:password])
      if user
        self.current_user = user
        redirect_to session[:previous_url] || root_path
      else
        @form = SignInForm.new(sign_in_params)
        flash.now[:alert] = "Your name or password is incorrect"
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
