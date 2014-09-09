class ApplicationController < ActionController::Base
  include ErrorHandling
  handle_as_unauthorized CanCan::AccessDenied

  protect_from_forgery with: :exception

  before_action :verify_name
  after_filter :store_location

  private
  def verify_name
    if user_signed_in? && current_user.name.blank?
      redirect_to [:edit, current_user]
    end
  end

  def current_user
    if session[:su]
      User.find session[:su]
    else
      super
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, params)
  end

  def store_location
    return unless request.get?
    if (request.path != "/users/auth/github" &&
        request.path != "/users/sign_out" &&
        !request.xhr?)
      session[:previous_url] = request.fullpath
    end
  end

end
