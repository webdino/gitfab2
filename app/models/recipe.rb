class Recipe < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:id, :user_id, :group_id, :name, :title, :description, :photo,
    materials_attributes:   [:id, :name, :url, :quantity, :size, :description, :photo, :_destroy],
    tools_attributes:       [:id, :name, :url, :description, :photo, :_destroy],
    statuses_attributes:    [:id, :description, :photo, :_destroy,
      way_set_attributes:    [:id, :recipe_id, :_destroy, ways_attributes: [:id, :description, :photo, :_destroy]],
    ],
    usages_attributes:      [:id, :description, :photo, :_destroy],
  ]
  COMMITABLE_ITEM_ASSOCS = [:statuses, :materials, :tools]
  ITEM_ASSOCS = COMMITABLE_ITEM_ASSOCS + [:usages]

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  acts_as_taggable
  acts_as_commentable
  acts_as_votable

  mount_uploader :photo, PhotoUploader

  searchable do
    string :name
    string :title
    string :description
    integer :user_id
  end

  belongs_to :user
  belongs_to :orig_recipe,    class_name: Recipe.name
  belongs_to :last_committer, class_name: User.name
  belongs_to :group
  has_many :contributor_recipes, foreign_key: :recipe_id, dependent: :destroy
  has_many :contributors, through: :contributor_recipes
  has_many :materials, dependent: :destroy
  has_many :statuses, dependent: :destroy
  has_many :tools, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :post_attachments, dependent: :destroy
  has_many :usages, dependent: :destroy
  has_many :collaborators, through: :collaborations, source: :user
  has_many :collaborations, foreign_key: :recipe_id, dependent: :destroy

  accepts_nested_attributes_for :materials, :tools, :statuses, allow_destroy: true

  after_create :ensure_repo_exist!
  before_update :rename_repo_name!, if: ->{self.name_changed?}
  after_destroy :destroy_repo!

  validates :name, presence: true

  paginates_per 10

  searchable do
    text :name, :title, :description
    ITEM_ASSOCS.each do |assoc|
      text assoc do
        self.send(assoc).map do |record|
          (assoc.to_s.classify.constantize)::FULLTEXT_SEARCHABLE_COLUMNS.map do |col|
            record.send col
          end
        end.flatten
      end
    end
  end

  def owner
    self.group || self.user
  end

  def owner= owner
    case owner
    when Group
      self.group_id = owner.id
    when User
      self.user_id = owner.id
    else
      raise "error"
    end
  end

  def repo
    Rugged::Repository.new repo_path if File.exists? repo_path
  end

  def commit!
    contents = [{file_path: "recipe.json", data: self.to_json}]
    COMMITABLE_ITEM_ASSOCS.each do |dir|
      items = self.send dir
      items.each do |item|
        contents << {file_path: item.to_path, data: item.to_json}
        if item.photo.present?
          contents << {file_path: item.photo_path, data: File.open(item.photo.path).read}
        end
      end
    end
    opts = {email: self.last_committer.try(:email), name: self.last_committer.try(:name)}
    Gitfab::Shell.new.commit_to_repo! self.repo.path, contents, opts
  end

  def fork_for! owner
    Recipe.transaction do
      self.dup.tap do |recipe|
        recipe.owner = owner
        recipe.statuses = self.statuses.collect{|status| status.dup_with_photo}
        recipe.materials = self.materials.collect{|material| material.dup_with_photo}
        recipe.tools = self.tools.collect{|tool| tool.dup_with_photo}
        recipe.orig_recipe = self
        recipe.name = Gitfab::Shell.new
          .copy_repo! self.repo.path, owner.dir_path, recipe.name
        recipe.save
      end
    end
  end

  def fill_default_name_for! user
    suffix = 1
    names = user.recipes.map &:name
    while names.include? (candidate = "recipe#{suffix}") do
      suffix += 1
    end
    self.name = candidate
  end

  private
  def ensure_repo_exist!
    Gitfab::Shell.new.add_repo! repo_path
  end

  def repo_path
    if self.group
      "#{self.group.dir_path}/#{self.name}.git"
    else
      "#{self.user.dir_path}/#{self.name}.git"
    end
  end

  def destroy_repo!
    Gitfab::Shell.new.destroy_repo! self.repo.path
  end

  def rename_repo_name!
    old_name, new_name = self.name_change
    old_path = "#{self.owner.dir_path}/#{old_name}.git"
    Gitfab::Shell.new.move_repo! old_path, self.owner.dir_path, self.name
  end
end
