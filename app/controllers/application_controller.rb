class ApplicationController < ActionController::Base
  include Gitfab::ErrorHandling
  handle_as_unauthorized CanCan::AccessDenied

  protect_from_forgery with: :exception

  before_action :verify_name

  private
  def verify_name
    if user_signed_in? and current_user.name.blank?
      redirect_to [:edit, current_user]
    end
  end
end
