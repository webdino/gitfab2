class SessionsController < ApplicationController
  def create
    user = User.find_for_github_oauth(request.env['omniauth.auth'])
    if user.persisted?
      self.current_user = user
      redirect_to session[:previous_url] || root_path
    else
      session['auth.failed.error'] = user.errors.full_messages
      redirect_to root_path
    end
  end

  def destroy
    self.current_user = nil
    redirect_to root_path
  end
end
