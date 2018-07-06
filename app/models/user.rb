class User < ActiveRecord::Base
  include ProjectOwner
  include Liker
  include Collaborator
  include DraftGenerator

  extend FriendlyId
  friendly_id :name, use: :slugged

  devise :omniauthable, omniauth_providers: [:github]
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  mount_uploader :avatar, AvatarUploader

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :notifications_given, class_name: 'Notification', inverse_of: :notifier, foreign_key: :notifier_id
  has_many :my_notifications, class_name: 'Notification', inverse_of: :notified, foreign_key: :notified_id

  accepts_nested_attributes_for :memberships, allow_destroy: true

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, if: -> { self.persisted? }
  validates :name, unique_owner_name: true,
                   name_format: true, if: -> { name.present? }

  def is_system_admin?
    authority == 'admin'
  end

  def is_owner_of?(project)
    self == project.owner
  end

  def is_contributor_of?(target)
    target.contributions.each do |contribution|
      return true if contribution.contributor_id == self.id
    end
    false
  end

  def membership_in(group)
    memberships.find_by group_id: group.id
  end

  [:admin, :editor, :member].each do |role|
    define_method "is_#{role}_of?" do |group|
      return false unless group
      group.send(role.to_s.pluralize).include? self
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      data = session['devise.github_data']
      if data && data['extra']['raw_info'] && user.email.blank?
        user.email = data['email']
      end
    end
  end

  def join_to(group)
    memberships.find_or_create_by group_id: group.id
  end

  def liked_projects
    Project.joins(:likes).merge(Like.where(liker: self))
  end

  def is_in_collaborated_group?(project)
    is_in_collaborated_group = false
    project.collaborators.each do |collaborator|
      if collaborator.class.name == Group.name
        is_in_collaborated_group ||= self.is_member_of?(collaborator)
      end
    end
    is_in_collaborated_group
  end

  def generate_draft
    "#{name}\n#{fullname}\n#{url}\n#{location}"
  end

  class << self
    def find_for_github_oauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.nickname
        user.fullname = auth.info.name
        user.remote_avatar_url = auth.info.image
      end
    end

    def updatable_columns
      [:avatar, :url, :location, memberships_attributes: Membership.updatable_columns]
    end
  end

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
