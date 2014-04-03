class Group < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :name, :creator, member_ids: []]

  after_create :add_initial_member

  belongs_to :creator, class_name: User.name
  has_many :memberships, foreign_key: :group_id
  has_many :members, through: :memberships, source: :user
  has_many :recipes

  validates :name, presence: true, uniqueness: true

  Membership::ROLE.keys.each do |role|
    define_method role.to_s.pluralize do
      self.members.joins(:memberships)
        .where "memberships.role" => Membership::ROLE[role]
    end

    define_method "add_#{role}" do |user|
      self.memberships.create user: user, role: Membership::ROLE[role]
    end
  end

  private
  def add_initial_member
    self.memberships.create user: self.creator, role: Membership::ROLE[:owner]
  end
end
