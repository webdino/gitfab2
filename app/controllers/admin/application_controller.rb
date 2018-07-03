class Admin::ApplicationController < ApplicationController
  layout 'dashboard'

  before_action do
    if !signed_in? || !current_user.is_system_admin?
      redirect_to(root_path)
    end
  end
end
