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

  searchable_field :name
  searchable_field :title
  searchable_field :description
  slug :name, scope: :owner_id

  has_many :derivatives, class_name: Project.name, inverse_of: :original
  belongs_to :original, class_name: Project.name, inverse_of: :derivatives
  belongs_to :owner, polymorphic: true
  embeds_many :usages, class_name: Card::Usage.name, cascade_callbacks: true
  embeds_one :recipe, autobuild: true, cascade_callbacks: true
  embeds_one :note, autobuild: true, cascade_callbacks: true

  after_initialize ->{self.name = SecureRandom.uuid}, if: ->{new_record? && name.blank?}
  after_create :ensure_a_figure_exists
  after_create :create_recipe_and_note

  validates :name, presence: true, name_format: true
  validates :name, uniqueness: {scope: [:owner_id, :owner_type]}
  validates :title, presence: true

  index "note.num_cards" => 1
  scope :noted, ->{where :"note.num_cards".gt => 0}

  accepts_nested_attributes_for :usages

  paginates_per 12

  searchable do
    string :name, :title, :owner_type
    string :owner_id
    text :description

    text :recipe do
      self.recipe.recipe_cards.map do |card|
        Card.searchable_fields.map do |col|
          card.send col
        end
      end.flatten
    end

    text :owner do
      (self.owner.class)::FULLTEXT_SEARCHABLE_COLUMNS.map do |col|
        self.owner.send col
      end
    end
  end

  def fork_for! owner
    dup.tap do |project|
      project.id = BSON::ObjectId.new
      project.owner = owner
      project.original = self
      project.save!
      project.recipe = recipe.dup_document
      project.note = note.dup_document
      project.usages = usages.map{|u| u.dup_content}
      project.figures = figures.map{|a| a.dup_document}
      names = owner.projects.pluck :name
      _name = name.dup
      if names.include? _name
        _name << "-1"
        _name.sub!(/(\d+)$/, "#{$1.to_i + 1}") while names.include? _name
      end
      project.name = _name
      begin
        project.save!
      rescue Exception => e
        project.destroy
        raise
      end
    end
  end

  def collaborators
    User.where("collaborations.project_id" => id)
  end

  class << self
    def updatable_columns
      [:name, :title, :description, :owner_id, :owner_type,
       usages_attributes: Card::Usage.updatable_columns,
       figures_attributes: Figure.updatable_columns
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
