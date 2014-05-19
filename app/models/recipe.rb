class Recipe < ActiveRecord::Base
  UPDATABLE_COLUMNS = [:name, :title, :description, :photo, :owner_id, :owner_type, :video_id]
  ITEM_ASSOCS = [:statuses, :materials, :tools, :usages]

  mount_uploader :photo, PhotoUploader
  include Gitfab::HasVideoOrPhoto

  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders, :scoped], scope: [:owner_id, :owner_type]

  acts_as_taggable
  acts_as_commentable
  acts_as_votable

  belongs_to :owner, polymorphic: true
  belongs_to :orig_recipe,    class_name: Recipe.name
  belongs_to :last_committer, class_name: User.name
  has_many :contributor_recipes, foreign_key: :recipe_id, dependent: :destroy
  has_many :contributors, through: :contributor_recipes
  has_many :materials, dependent: :destroy
  has_many :statuses, dependent: :destroy
  has_many :ways, through: :statuses
  has_many :tools, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :usages, dependent: :destroy
  has_many :collaborators, through: :collaborations, source: :user
  has_many :collaborations, foreign_key: :recipe_id, dependent: :destroy

  accepts_nested_attributes_for :materials, :tools, :statuses, allow_destroy: true

  after_commit ->{reassoc_ways; ensure_terminate_making_flow_with_a_status}

  # TODO unique in owner
  validates :name, presence: true, name_format: true
  validates :title, presence: true

  paginates_per 12

  searchable do
    string :name, :title, :owner_type
    integer :owner_id
    text :description
    ITEM_ASSOCS.each do |assoc|
      text assoc do
        self.send(assoc).map do |record|
          (assoc.to_s.classify.constantize)::FULLTEXT_SEARCHABLE_COLUMNS.map do |col|
            record.send col
          end
        end.flatten
      end
    end
    text :owner do
      (self.owner.class)::FULLTEXT_SEARCHABLE_COLUMNS.map do |col|
        self.owner.send col
      end
    end
  end

  def owner
    klass = self.owner_type.constantize
    klass.find self.owner_id
  end

  def owner= owner
    self.owner_id = owner.id
    self.owner_type = owner.class.name
  end

  def dup_with_photo
    self.dup.tap{|item| item.photo = dup_photo if self.photo.present?}
  end

  def fork_for! owner
    Recipe.transaction do
      self.dup_with_photo.tap do |recipe|
        recipe.owner = owner
        recipe.statuses = self.statuses.collect{|status| status.dup_with_photo_and_ways}
        recipe.materials = self.materials.collect{|material| material.dup_with_photo}
        recipe.tools = self.tools.collect{|tool| tool.dup_with_photo}
        recipe.orig_recipe = self

        names = owner.recipes.pluck :name
        _name = recipe.name.dup
        _name << "_" while names.include? _name
        recipe.name = _name
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

  def remove_unused_items!
    existing_items = {"tool" => [0], "material" => [0]}.tap do |_existing_items|
      ["statuses", "ways", "usages"].each do |assoc|
        self.send(assoc).each do |item|
          doc = Nokogiri::HTML.parse item.description
          doc.css("a").each do |anchor|
            item_id = anchor.attribute("data-item-id").try :value
            item_type = anchor.attribute("data-item-type").try :value
            if item_id && item_type && item_type != "null"
              _existing_items[item_type] << item_id
            end
          end
        end
      end
    end
    existing_items.each do |type, ids|
      self.send(type.pluralize).where.not(id: ids).destroy_all
    end
  end

  private
  def reassoc_ways
    Way.transaction do
      self.ways.where("ways.reassoc_token is not null")
        .where("ways.reassoc_token <> ''").each do |way|
          status = self.statuses.find_by reassoc_token: way.reassoc_token
          way.update_attributes status_id: status.id, reassoc_token: nil
      end
    end
  end

  def ensure_terminate_making_flow_with_a_status
    self.statuses.create if self.statuses.sorted_by_position.last.ways.any?
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  def dup_photo
    ActionDispatch::Http::UploadedFile.new filename: self.photo.file.filename,
      type: self.photo.file.content_type, tempfile: File.open(self.photo.path)
  end
end
