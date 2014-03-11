class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :verify_name

  private
  def verify_name
    if user_signed_in? and current_user.name.blank?
      redirect_to [:edit, current_user]
    end
  end
end
