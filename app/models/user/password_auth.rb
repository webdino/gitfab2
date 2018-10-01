# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  authority              :string(255)
#  avatar                 :string(255)
#  email                  :string(255)      not null
#  location               :string(255)
#  name                   :string(255)
#  password_digest        :string(255)
#  projects_count         :integer          default(0), not null
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  slug                   :string(255)
#  url                    :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_name   (name) UNIQUE
#  index_users_on_slug   (slug) UNIQUE
#

# frozen_string_literal: true

class User::PasswordAuth < User
  has_secure_password

  validates :password, length: { minimum: 6 }

  def self.model_name
    User.model_name
  end

  def password_auth?
    true
  end

  def send_reset_password_instructions(token: SecureRandom.urlsafe_base64, sent_at: Time.current)
    update_columns(reset_password_token: token, reset_password_sent_at: sent_at)
    UserMailer.reset_password_instructions(email, token).deliver_now
  end

  def reset_password_period_valid?
    !!reset_password_sent_at && reset_password_sent_at >= 3.hours.ago
  end

  def clear_reset_password_attrs
    update_columns(reset_password_token: nil, reset_password_sent_at: nil)
  end
end
