class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  unless Rails.env.development?
    rescue_from StandardError, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
  end

  rescue_from CanCan::AccessDenied do
    render file: "public/401.html", status: :unauthorized
  end

  before_action :verify_name
  after_action :store_location

  def current_user
    @current_user ||= begin
      return unless session[:su]
      User.readonly.find_by(id: session[:su])
    end
  end
  helper_method :current_user

  def current_user=(user)
    session[:su] = user&.id
    @current_user = user
  end

  private

  def verify_name
    if current_user && current_user.name.blank?
      redirect_to [:edit, current_user]
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, params)
  end

  def store_location
    return unless request.get?
    return if request.xhr?
    return if ['/users/auth/github', '/users/sign_out'].include?(request.path)
    session[:previous_url] = request.fullpath
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_401(_exception = nil)
    render file: Rails.root.join('public/401.html'), status: 401, layout: false, content_type: 'text/html'
  end

  def render_403(_exception = nil)
    render file: Rails.root.join('public/403.html'), status: 403, layout: false, content_type: 'text/html'
  end

  def render_404(_exception = nil)
    render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
  end

  def render_500(exception = nil)
    if exception
      Rails.logger.error(exception)
      exception.backtrace.each do |f|
        Rails.logger.error("  #{f}")
      end
    end
    env = request.env
    method = env['REQUEST_METHOD']
    path = env['REQUEST_PATH']
    user_agent = env['HTTP_USER_AGENT']
    message = "#{method} '#{path}' \n UA: '#{user_agent}'"
    ExceptionNotifier.notify_exception exception, env: env, data: { message: message }
    render file: Rails.root.join('public/500.html'), status: 500, layout: false, content_type: 'text/html'
  end
end
