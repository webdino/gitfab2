class Recipe < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:owner_id, :name, :title, :description, :photo,
    materials_attributes: [:name, :url, :quantity, :size, :description, :photo],
    tools_attributes: [:name, :url, :description, :photo],
    statuses_attributes: [:description, :photo],
    ways_attributes: [:description, :photo]
  ]
  mount_uploader :photo, PhotoUploader
  belongs_to :owner
  belongs_to :last_committer, class_name: User.name
  belongs_to :orig_recipe, class_name: Recipe.name
  has_many :contributors, through: :contributor_recipes
  has_many :contributor_recipes
  has_many :materials
  has_many :tools
  has_many :statuses
  has_many :ways
  accepts_nested_attributes_for :materials, :tools, :statuses, :ways

  after_create :ensure_repo_exist!
  after_save :commit_to_repo!

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

  def fork_for user
    recipe = self.dup
    recipe.orig_recipe = self
    recipe.owner = user
    recipe
  end

  private
  def ensure_repo_exist!
    ::Gitfab::Shell.new.add_repo! repo_path
  end

  def repo_path
    "#{self.owner.dir_path}/#{self.name}.git"
  end

  def commit_to_repo!
    contents = [{file_path: "recipe.json", data: self.to_json}]
    opts = {email: self.last_committer.email, name: self.last_committer.name}
    ::Gitfab::Shell.new.commit_to_repo! repo_path, contents, opts
  end
end
