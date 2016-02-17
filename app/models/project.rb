class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Figurable
  include Commentable
  include Contributable
  include Taggable
  include Likable
  include Searchable
  include Notificatable

  searchable_field :name
  searchable_field :title
  searchable_field :description
  searchable_field :is_private, type: :boolean
  searchable_field :owner_id
  slug :name, scope: :owner_id

  field :license, type: :integer

  has_many :derivatives, class_name: Project.name, inverse_of: :original
  belongs_to :original, class_name: Project.name, inverse_of: :derivatives
  belongs_to :owner, polymorphic: true, index: true, counter_cache: :projects_count
  embeds_many :usages, class_name: Card::Usage.name, cascade_callbacks: true
  embeds_one :recipe, autobuild: true, cascade_callbacks: true
  embeds_one :note, autobuild: true, cascade_callbacks: true

  after_initialize -> { self.name = SecureRandom.uuid, self.license = 0 }, if: -> { new_record? && name.blank? }
  after_create :ensure_a_figure_exists
  after_create :create_recipe_and_note

  validates :name, presence: true, name_format: true
  validates :name, uniqueness: { scope: [:owner_id, :owner_type] }
  validates :title, presence: true

  index updated_at: -1
  index 'note.num_cards' => 1
  scope :noted, -> { where :"note.num_cards".gt => 0 }
  scope :ordered_by_owner, -> { order('owner_id ASC') }

  accepts_nested_attributes_for :usages

  paginates_per 12

  searchable do
    text :name
    text :title
    text :description
    string :owner_type
    string :owner_id
    boolean :is_private

    text :tags do
      tags.map(&:name).flatten
    end

    text :recipe do
      recipe.states.map do |card|
        Card.searchable_fields.map do |col|
          card.send col
        end
      end.flatten
    end

    text :owner do
      (owner.class)::FULLTEXT_SEARCHABLE_COLUMNS.map do |col|
        owner.send col
      end
    end
  end

  # TODO: This fork_for fucntion should be devided.
  def fork_for!(owner)
    dup.tap do |project|
      project.id = BSON::ObjectId.new
      project.owner = owner
      project.original = self
      names = owner.projects.pluck :name
      new_project_name = name.dup
      if names.include? new_project_name
        new_project_name << '-1'
        new_project_name.sub!(/(\d+)$/, "#{Regexp.last_match(1).to_i + 1}") while names.include? new_project_name
      end
      project.name = new_project_name
      project.save!
      project.recipe = recipe.dup_document
      project.figures = figures.map(&:dup_document)
      project.likes = []
      project.usages = []
      project.note.note_cards = []
      begin
        project.save!
      rescue => _e
        project.destroy
        raise
      end
    end
  end

  def change_owner!(owner)
    self.owner = owner
    self.save!
    #   if project.collaborators.include?(new_owner)
    #     old_collaboration = new_owner.collaboration_in project
    #     old_collaboration.destroy
    #   end
    # else
    #   return false
    # end
  end

  def managers
    users = []
    if owner.is_a? User
      users << owner
    else
      users += owner.members
    end
    users
  end

  def collaborate_users
    users = []
    collaborators.each do |collaborator|
      if collaborator.is_a? User
        users << collaborator
      else
        users += collaborator.members
      end
    end
    users
  end

  # TODO: This function should have less than 10 line.
  def potential_owners
    owner_list = []
    owner = self.owner
    if owner.instance_of?(User)
      owner.memberships.each do |membership|
        owner_list.push membership.group
      end
    else
      owner.members.each do |member|
        owner_list.push member
      end
    end
    collaborators.each do |collaborator|
      owner_list.push collaborator
    end
    owner_list
  end

  def thumbnail
    if figures.first.link.present?
      'https://img.youtube.com/vi/' + figures.first.link.split('/').last + '/mqdefault.jpg'
    elsif figures.first.content.present?
      figures.first.content.small
    else
      'fallback/blank.png'
    end
  end

  def collaborators
    users = User.where('collaborations.project_id' => id)
    groups = Group.where('collaborations.project_id' => id)
    users.concat groups
  end

  def licenses
    ['by', 'by-sa', 'by-nc', 'by-nc-sa']
  end

  class << self
    def updatable_columns
      [:name, :title, :description, :owner_id, :owner_type, :is_private, :license,
       usages_attributes: Card::Usage.updatable_columns,
       figures_attributes: Figure.updatable_columns,
       likes_attributes: Like.updatable_columns
      ]
    end
  end

  private

  def ensure_a_figure_exists
    figures.create if figures.none?
  end

  def create_recipe_and_note
    create_recipe
    create_note
  end
end
