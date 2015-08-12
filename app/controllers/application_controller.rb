class ApplicationController < ActionController::Base
  include ErrorHandling
  protect_from_forgery with: :exception

  UnauthorizedError = Class.new(ActionController::ActionControllerError)
  IllegalAccessError = Class.new(ActionController::ActionControllerError)

  rescue_from Exception, with: :render_500
  rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, with: :render_404
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

  def render_401(e = nil)
    render file: Rails.root.join("public/401.html"), status: 401, layout: false, content_type: "text/html"
  end

  def render_403(e = nil)
    render file: Rails.root.join("public/403.html"), status: 403, layout: false, content_type: "text/html"
  end

  def render_404(e = nil)
    render file: Rails.root.join("public/404.html"), status: 404, layout: false, content_type: "text/html"
  end

  def render_500(e = nil)
    ExceptionNotifier.notify_exception e, env: request.env, data: {message: "500 error occured"}
    render file: Rails.root.join("public/500.html"), status: 500, layout: false, content_type: "text/html"
  end

end
