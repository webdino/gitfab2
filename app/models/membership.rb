class Membership < ActiveRecord::Base
  ROLE = { admin: 'admin', editor: 'editor' }

  belongs_to :user, required: true
  belongs_to :group, required: true

  after_create -> { update_attributes role: ROLE[:admin] }, if: -> { group.admins.none? }
  # after_destroy -> { group.destroy }, if: -> { group && group.members.none? }
  validates :role, presence: :true

  Membership::ROLE.keys.each do |role|
    define_method "#{role}?" do
      Membership::ROLE[role] == self.role
    end
  end

  class << self
    def updatable_columns
      [:id, :group_id, :role, :_destroy]
    end
  end
end
