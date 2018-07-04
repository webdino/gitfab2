class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = User.find_for_github_oauth request.env['omniauth.auth']
    if @user.persisted?
      sign_in @user, event: :authentication
      redirect_to session[:previous_url] || root_path
      if is_navigational_format?
        set_flash_message :notice, :success, kind: 'Github'
      end
    else
      session['devise.github_data'] = request.env['omniauth.auth']
      session['auth.failed.error'] = @user.errors.full_messages
      redirect_to root_path
    end
  end
end
