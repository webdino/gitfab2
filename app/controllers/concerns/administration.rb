module Administration
  extend ActiveSupport::Concern

  included do
    before_action do
      if signed_in? && current_user.is_system_admin?
        true
      else
        redirect_to(root_path)
        false
      end
    end
  end

end
