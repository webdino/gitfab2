class SessionsController < ApplicationController
  def create
    user = User.find_for_github_oauth(request.env['omniauth.auth'])
    if user.persisted?
      session[:su] = user.id
      @current_user = user
      redirect_to session[:previous_url] || root_path
    else
      session['auth.failed.error'] = user.errors.full_messages
      redirect_to root_path
    end
  end

  def destroy
    @current_user = nil
    session.delete(:su)
    redirect_to root_path
  end
end
