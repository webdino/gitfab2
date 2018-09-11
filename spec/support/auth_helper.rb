module AuthHelper
  def sign_in(user)
    session[:su] = user.id
  end
end
