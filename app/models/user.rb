class User < ActiveRecord::Base
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :fullname]
  UPDATABLE_COLUMNS = [:name, :avatar]

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  acts_as_voter

  devise :omniauthable, omniauth_providers: [:github]
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  mount_uploader :avatar, AvatarUploader

  has_many :recipes, as: :owner, dependent: :destroy
  has_many :contributor_recipes, foreign_key: :contributor_id
  has_many :contributing_recipes, through: :contributor_recipes, source: :recipe
  has_many :memberships, foreign_key: :user_id, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :collaborating_recipes, through: :collaborations, source: :recipe
  has_many :collaborations, foreign_key: :user_id, dependent: :destroy
  has_many :posts
  has_many :ways, as: :creator

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, if: ->{self.persisted?}
  validates :name, unique_owner_name: true,
    name_format: true, if: ->{self.name.present?}

  def is_owner_of? recipe
    self == recipe.owner
  end

  def is_collaborator_of? recipe
    recipe.collaborators.include? self
  end

  def is_creator_of? record
    return false unless record.respond_to? :creator
    self == record.creator
  end

  def is_admin_of? group
    return false unless group
    group.admins.include? self
  end

  def membership_in group
    self.memberships.find_by group_id: group.id
  end

  [:admin, :editor, :member].each do |role|
    define_method "is_#{role}_of?" do |group|
      return false unless group
      group.send(role.to_s.pluralize).include? self
    end
  end

  def self.new_with_session params, session
    super.tap do |user|
      data = session["devise.github_data"]
      if data && data["extra"]["raw_info"] && user.email.blank?
        user.email = data["email"]
      end
    end
  end

  class << self
    def find_for_github_oauth auth
      where(auth.slice :provider, :uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.nickname
        user.fullname = auth.info.name
        user.remote_avatar_url = auth.info.image
      end
    end
  end

  private
  def should_generate_new_friendly_id?
    name_changed?
  end
end
