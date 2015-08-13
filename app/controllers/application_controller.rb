class ApplicationController < ActionController::Base
  include ErrorHandling
  protect_from_forgery with: :exception

  UnauthorizedError = Class.new(ActionController::ActionControllerError)
  IllegalAccessError = Class.new(ActionController::ActionControllerError)

  rescue_from Exception, with: :render_500
  rescue_from Mongoid::Errors::DocumentNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from UnauthorizedError, with: :render_401
  rescue_from IllegalAccessError, with: :render_403
  handle_as_unauthorized CanCan::AccessDenied

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

  def render_401(exception = nil)
    render file: Rails.root.join("public/401.html"), status: 401, layout: false, content_type: "text/html"
  end

  def render_403(exception = nil)
    render file: Rails.root.join("public/403.html"), status: 403, layout: false, content_type: "text/html"
  end

  def render_404(exception = nil)
    render file: Rails.root.join("public/404.html"), status: 404, layout: false, content_type: "text/html"
  end

  def render_500(exception = nil)
    env = request.env
    method = env["REQUEST_METHOD"]
    path = env["REQUEST_PATH"]
    user_agent = env["HTTP_USER_AGENT"]
    message = "#{method} '#{path}' \n UA: '#{user_agent}'"
    ExceptionNotifier.notify_exception exception, env: env, data: {message: message}
    render file: Rails.root.join("public/500.html"), status: 500, layout: false, content_type: "text/html"
  end

end
