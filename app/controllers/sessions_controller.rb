class SessionsController < ApplicationController
  def index
  end

  def create
    auth = request.env["omniauth.auth"]
    identity = Identity.find_or_create_with_omniauth(auth)

    if identity.user
      self.current_user = identity.user
      redirect_to session[:previous_url] || root_path
    else
      redirect_to new_user_path(token: identity.encrypted_id)
    end
  end

  def destroy
    self.current_user = nil
    redirect_to root_path
  end
end
