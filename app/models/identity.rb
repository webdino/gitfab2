# == Schema Information
#
# Table name: identities
#
#  id         :bigint(8)        not null, primary key
#  email      :string(255)
#  image      :text(65535)
#  name       :string(255)
#  nickname   :string(255)
#  provider   :string(255)
#  uid        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_identities_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user, optional: true # OAuth認証してからユーザー登録するまではnullになる

  def self.find_or_create_with_omniauth(auth)
    find_or_create_by(uid: auth.uid, provider: auth.provider) do |identity|
      identity.email = auth.info.email
      identity.nickname = auth.info.nickname
      identity.name = auth.info.name
      identity.image = auth.info.image
    end
  end

  def self.crypt
    ActiveSupport::MessageEncryptor.new(Rails.application.secret_key_base)
  end

  def self.find_by_encrypted_id(encrypted_id)
    find(crypt.decrypt_and_verify(Base64.urlsafe_decode64(encrypted_id)))
  end

  def encrypted_id
    Base64.urlsafe_encode64(self.class.crypt.encrypt_and_sign(id))
  end
end
