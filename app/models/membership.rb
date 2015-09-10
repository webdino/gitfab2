class Membership
  ROLE = { admin: 'admin', editor: 'editor' }

  include Mongoid::Document
  include Mongoid::Timestamps

  field :group_id
  field :role, default: ROLE[:editor]

  embedded_in :user
  belongs_to :group

  before_validation :must_have_user_and_group
  after_create -> { update_attributes role: ROLE[:admin] }, if: -> { group.admins.none? }
  after_destroy -> { group.destroy }, if: -> { group.members.none? }
  validates :group_id, :role, presence: :true

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

  private

  def must_have_user_and_group
    errors.add :user, 'Error' if user.blank?
    errors.add :group, 'Error' if group.blank?
  end
end
