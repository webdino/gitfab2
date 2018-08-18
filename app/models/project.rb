# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  description :text(65535)
#  draft       :text(65535)
#  is_deleted  :boolean          default(FALSE), not null
#  is_private  :boolean          default(FALSE), not null
#  license     :integer
#  likes_count :integer          default(0), not null
#  name        :string(255)      not null
#  owner_type  :string(255)      not null
#  scope       :string(255)
#  slug        :string(255)
#  title       :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  original_id :integer
#  owner_id    :integer          not null
#
# Indexes
#
#  index_projects_on_is_private_and_is_deleted  (is_private,is_deleted)
#  index_projects_original_id                   (original_id)
#  index_projects_owner                         (owner_type,owner_id)
#  index_projects_slug_owner                    (slug,owner_type,owner_id) UNIQUE
#  index_projects_updated_at                    (updated_at)
#

class Project < ApplicationRecord
  include Figurable
  include Notificatable

  extend FriendlyId
  friendly_id :name, use: %i(slugged scoped), scope: :owner_id

  belongs_to :original, class_name: 'Project', inverse_of: :derivatives, optional: true
  belongs_to :owner, polymorphic: true
  has_many :derivatives, class_name: 'Project', foreign_key: :original_id, inverse_of: :original
  has_many :likes, dependent: :destroy
  has_many :note_cards, class_name: 'Card::NoteCard', dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :usages, class_name: 'Card::Usage', dependent: :destroy
  has_one :recipe, dependent: :destroy

  before_save :set_draft

  after_initialize -> { self.name = SecureRandom.uuid, self.license = 0 }, if: -> { new_record? && name.blank? }
  after_create :ensure_a_figure_exists
  after_create -> { create_recipe unless recipe }
  after_commit -> { owner.update_projects_count }

  validates :name, presence: true, name_format: true
  validates :name, uniqueness: { scope: [:owner_id, :owner_type] }
  validates :title, presence: true

  scope :noted, -> do
    note_cards_sql = Card::NoteCard.select(:id).group(:project_id).having("COUNT(id) > 0")
    joins(:note_cards).where(cards: { id: note_cards_sql })
  end
  scope :ordered_by_owner, -> { order(:owner_id) }
  scope :published, -> { where(is_private: false, is_deleted: false) }

  # draft全文検索
  scope :search_draft, -> (text) do
    projects = all
    text.split(/\p{space}+/).each do |word|
      projects = projects.where("#{table_name}.draft LIKE ?", "%#{word}%")
    end
    projects
  end

  accepts_nested_attributes_for :usages

  paginates_per 12

  def self.find_with(owner_slug, project_slug)
    Owner.find(owner_slug).projects.friendly.find(project_slug)
  end

  # このプロジェクトを owner のプロジェクトとしてフォークする
  def fork_for!(owner)
    # 整合性を保つため1トランザクション内でデータを準備
    transaction do
      dup.tap do |project|
        project.owner = owner
        project.original = self
        names = owner.projects.pluck :name
        new_project_name = name.dup
        if names.include? new_project_name
          new_project_name << '-1'
          new_project_name.sub!(/(\d+)$/, "#{Regexp.last_match(1).to_i + 1}") while names.include? new_project_name
        end
        project.name = new_project_name
        project.recipe = recipe.dup_document
        project.figures = figures.map(&:dup_document)
        project.likes = [] # reset counter
        project.usages = []

        project.save!
        project.recipe.save!
      end
    end
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

  def root project
    return project if project.original.blank? || Project.where(id: project.original_id).length == 0
    root project.original
  end

  def thumbnail
    if figures.first.link.present?
      'https://img.youtube.com/vi/' + figures.first.link.split('/').last + '/mqdefault.jpg'
    elsif figures.first.content.present?
      figures.first.content.small.url
    else
      '/images/fallback/blank.png'
    end
  end

  def collaborators
    users = User.joins(:collaborations).where('collaborations.project_id' => id)
    groups = Group.joins(:collaborations).where('collaborations.project_id' => id)
    users + groups
  end

  def licenses
    ['by', 'by-sa', 'by-nc', 'by-nc-sa']
  end

  def soft_destroy
    update(is_deleted: true)
  end

  def soft_destroy!
    update!(is_deleted: true)
  end

  def soft_restore
    update(is_deleted: false)
  end

  def soft_restore!
    update!(is_deleted: false)
  end

  def path
    [owner.name, title].join('/')
  end

  def update_draft!
    update!(draft: generate_draft)
  end

  class << self
    def updatable_columns
      [:name, :title, :description, :owner_type, :is_private, :is_deleted, :license,
       figures_attributes: Figure.updatable_columns
      ]
    end
  end

  private

    def ensure_a_figure_exists
      figures.create if figures.none?
    end

    def generate_draft
      lines = [name, title, description, owner.generate_draft]
      tags.each do |t|
        lines << t.generate_draft
      end
      lines << recipe.generate_draft if recipe
      lines.join("\n")
    end

    def set_draft
      self.draft = generate_draft
    end

    def should_generate_new_friendly_id?
      name_changed? || super
    end
end
