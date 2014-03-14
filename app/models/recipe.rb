class Recipe < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:user_id, :name, :title, :description, :photo,
    materials_attributes: [:name, :url, :quantity, :size, :description, :photo],
    tools_attributes:     [:name, :url, :description, :photo],
    statuses_attributes:  [:description, :photo],
    ways_attributes:      [:description, :photo]
  ]

  mount_uploader :photo, PhotoUploader

  belongs_to :user
  belongs_to :orig_recipe,    class_name: Recipe.name
  belongs_to :last_committer, class_name: User.name

  has_many :contributors, through: :contributor_recipes
  has_many :contributor_recipes
  has_many :materials
  has_many :statuses
  has_many :tools
  has_many :ways

  accepts_nested_attributes_for :materials, :tools, :statuses, :ways

  after_initialize :build_assocs!,     if: ->{self.new_record?}
  after_create :ensure_repo_exist!
  after_save :commit_to_repo!
  after_destroy :destroy_repo!

  validates :name, presence: true

  searchable do
    text :name, :title, :description
    [:materials, :tools, :statuses, :ways].each do |assoc|
      text assoc do
        self.send(assoc).map do |record|
          (assoc.to_s.classify.constantize)::FULLTEXT_SEARCHABLE_COLUMNS.map do |col|
            record.send col
          end
        end.flatten
      end
    end
  end

  def fork_for! user
    Recipe.transaction do
      new_recipe = self.dup
      new_recipe.orig_recipe = self
      new_recipe.user_id = user.id
      new_recipe.name = Gitfab::Shell.new
        .copy_repo! self.repo_path, user.dir_path, new_recipe.name
      new_recipe.save
      new_recipe
    end
  end

  def repo_path
    "#{self.user.dir_path}/#{self.name}.git"
  end

  def fill_default_name_for! user
    suffix = 1
    names = user.recipes.map(&:name)
    while names.include? (candidate = "recipe#{suffix}") do
      suffix += 1
    end
    self.name = candidate
  end

  private
  def ensure_repo_exist!
    ::Gitfab::Shell.new.add_repo! repo_path
  end

  def commit_to_repo!
    contents = [{file_path: "recipe.json", data: self.to_json}]
    opts = {email: self.last_committer.try(:email), name: self.last_committer.try(:name)}
    ::Gitfab::Shell.new.commit_to_repo! repo_path, contents, opts
  end

  def destroy_repo!
    ::Gitfab::Shell.new.destroy_repo! self.repo_path
  end

  def build_assocs!
    self.materials.build
    self.tools.build
    self.statuses.build
    self.ways.build
  end
end
