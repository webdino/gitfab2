# frozen_string_literal: true

class PasswordsController < ApplicationController
  def new
  end

  def create
    user = User::PasswordAuth.find_by(email: params[:email])
    user&.send_reset_password_instructions
    flash[:success] = "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."
    redirect_to new_password_path
  end

  def edit
    if params[:reset_password_token].blank?
      flash[:danger] = "You can't access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided."
      redirect_to sessions_path
      return
    end

    @user = User::PasswordAuth.new(reset_password_token: params[:reset_password_token])
  end

  def update
    reset_password_token = params.dig(:user, :reset_password_token)
    @user = User::PasswordAuth.find_by(reset_password_token: reset_password_token)

    if @user.nil? || !@user.reset_password_period_valid?
      flash[:danger] = "Reset password token has expired, please request a new one"
      redirect_to new_password_path
      return
    end

    if @user.update(user_params)
      @user.clear_reset_password_attrs
      flash[:success] = "Your password has been changed successfully."
      redirect_to sessions_path
    else
      render :edit
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
