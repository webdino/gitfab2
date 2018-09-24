# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  authority       :string(255)
#  avatar          :string(255)
#  email           :string(255)
#  location        :string(255)
#  name            :string(255)
#  password_digest :string(255)
#  projects_count  :integer          default(0), not null
#  slug            :string(255)
#  url             :string(255)
#  created_at      :datetime
#  updated_at      :datetime
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
end
