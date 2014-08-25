class User
  FULLTEXT_SEARCHABLE_COLUMNS = [:name, :fullname]

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include ProjectOwner
  include Liker

  ## Database authenticatable
  field :email
  field :encrypted_password

  ## Rememberable
  field :remember_created_at, type: DateTime

  ## Trackable
  field :sign_in_count, default: 0, type: Integer
  field :current_sign_in_at, type: DateTime
  field :last_sign_in_at, type: DateTime
  field :current_sign_in_ip
  field :last_sign_in_ip

  # OmniAuth
  field :provider
  field :uid

  field :name
  slug :name
  field :fullname
  field :avatar

  devise :omniauthable, omniauth_providers: [:github]
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  mount_uploader :avatar, AvatarUploader

  embeds_many :memberships
  embeds_many :collaborations

  accepts_nested_attributes_for :memberships, allow_destroy: true

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, if: ->{self.persisted?}
  validates :name, unique_owner_name: true,
    name_format: true, if: ->{self.name.present?}

  def is_owner_of? project
    self == project.owner
  end

  def is_collaborator_of? project
    collaborations.where(project_id: project.id).exists?
  end

  def is_contributor_of? target
    target.contributions.each do |contribution|
      if contribution.contributor_id == self.slug
        return true
      end
    end
    return false
  end

  def is_admin_of? group
    return false unless group
    group.admins.include? self
  end

  def membership_in group
    memberships.find_by group_id: group.id
  end

  def collaboration_in project
    collaborations.find_by project_id: project.id
  end

  def collaborate! project
    collaborations.create project: project
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

  def groups
    Group.find memberships.map(&:group_id)
  end

  def join_to group
    memberships.find_or_create_by group_id: group.id
  end

  def liked_projects
    Project.where "likes.liker_id" => self.id
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

    def updatable_columns
      [:name, :avatar, memberships_attributes: Membership.updatable_columns]
    end
  end
end
