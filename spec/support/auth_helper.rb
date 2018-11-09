module AuthHelper
  def sign_in(user)
    session[:su] = user.id
  end

  def sign_out
    session.delete(:su)
  end
end
