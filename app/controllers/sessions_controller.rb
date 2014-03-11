class SessionsController < Devise::SessionsController
  skip_before_action :verify_name

  def create
    warden.authenticate! scope: resource_name
    render json: {success: true} 
  end
end
