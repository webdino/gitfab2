class Membership < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :user_id, :group_id, :role]
  ROLE = {admin: "admin", editor: "editor"}

  belongs_to :user
  belongs_to :group

  before_validation :must_have_user_and_group
  after_destroy ->{self.group.destroy}, if: ->{self.group.memberships.none?}
  validates :user_id, :group_id, :role, presence: :true
  validates :user_id, uniqueness: {scope: :group_id}

  Membership::ROLE.keys.each do |role|
    define_method "#{role}?" do
      Membership::ROLE[role] == self.role
    end
  end

  private
  def must_have_user_and_group
    if self.user.blank?
      self.errors.add :user, "Error"
    end
    if self.group.blank?
      self.errors.add :group, "Error"
    end
  end
end
