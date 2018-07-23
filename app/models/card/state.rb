# == Schema Information
#
# Table name: cards
#
#  id            :integer          not null, primary key
#  description   :text(4294967295)
#  position      :integer          default(0), not null
#  title         :string(255)
#  type          :string(255)      not null
#  created_at    :datetime
#  updated_at    :datetime
#  annotation_id :integer
#  project_id    :integer
#  recipe_id     :integer
#
# Indexes
#
#  index_cards_on_annotation_id  (annotation_id)
#  index_cards_project_id        (project_id)
#  index_cards_recipe_id         (recipe_id)
#
# Foreign Keys
#
#  fk_cards_project_id  (project_id => projects.id)
#  fk_cards_recipe_id   (recipe_id => recipes.id)
#

class Card::State < Card
  belongs_to :recipe
  acts_as_list scope: :recipe

  has_many :annotations, ->{ order(:position) },
                        class_name: 'Card::Annotation',
                        foreign_key: :annotation_id,
                        dependent: :destroy
  accepts_nested_attributes_for :annotations

  scope :ordered_by_position, -> { order('position ASC') }

  class << self
    def updatable_columns
      super + [:position, :move_to,
               annotations_attributes: Card::Annotation.updatable_columns
              ]
    end
  end

  def to_annotation!(parent_state)
    update!(type: Card::Annotation.name, annotation_id: parent_state.id)
    Card::Annotation.find(id)
  end

  def dup_document
    super.tap do |doc|
      doc.annotations = annotations.map(&:dup_document)
    end
  end
end

