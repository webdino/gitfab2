class UserMailer < ApplicationMailer
  def reset_password_instructions(email, token)
    @email = email
    @token = token
    mail(to: email, subject: "Reset password instructions")
  end

  def backup(token, user)
    @token = token
    @user = user
    mail(to: user.email, subject: 'Download your backup')
  end
end
