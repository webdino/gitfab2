class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  unless Rails.env.development?
    rescue_from StandardError, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
  end
  rescue_from CanCan::AccessDenied, with: :render_401

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

  def render_401(layout: false)
    render file: Rails.root.join('public/401.html'), status: :unauthorized, layout: layout
  end

  def render_403(layout: false)
    render file: Rails.root.join('public/403.html'), status: :forbidden, layout: layout
  end

  def render_404(layout: false)
    render file: Rails.root.join('public/404.html'), status: :not_found, layout: layout
  end

  private

    def store_location
      return unless request.get?
      return if request.xhr?
      return if request.path.start_with?('/password')
      return if request.path.start_with?('/users/auth')
      return if ['/users/new', '/users/sign_out', '/sessions'].include?(request.path)
      session[:previous_url] = request.fullpath
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
