class UserMailer < ApplicationMailer
  def reset_password_instructions(email, token)
    @email = email
    @token = token
    mail(to: email, subject: "Reset password instructions")
  end
end
