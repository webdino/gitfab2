# == Schema Information
#
# Table name: cards
#
#  id               :integer          not null, primary key
#  annotatable_type :string(255)
#  description      :text(4294967295)
#  position         :integer          default(0), not null
#  title            :string(255)
#  type             :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  annotatable_id   :integer
#  note_id          :integer
#  project_id       :integer
#  recipe_id        :integer
#
# Indexes
#
#  index_cards_annotatable  (annotatable_type,annotatable_id)
#  index_cards_note_id      (note_id)
#  index_cards_project_id   (project_id)
#  index_cards_recipe_id    (recipe_id)
#
# Foreign Keys
#
#  fk_cards_note_id     (note_id => notes.id)
#  fk_cards_project_id  (project_id => projects.id)
#  fk_cards_recipe_id   (recipe_id => recipes.id)
#

class Card::State < Card
  include Annotatable
  belongs_to :recipe, required: true
  acts_as_list scope: :recipe

  scope :ordered_by_position, -> { order('position ASC') }

  class << self
    def updatable_columns
      super + [:position, :move_to,
               annotations_attributes: Card::Annotation.updatable_columns
              ]
    end
  end

  # StateをAnnotationに変換
  # 基底のCardクラスとしてdupした上でAnnotationとしてparent_stateの子に設定する
  def to_annotation!(parent_state)
    annotation = nil
    transaction do
      Card.uncached do
        card = self.class.lock.find(id).tap{ |c| c.type = Card.name }.becomes(Card)
        # annotation = card.dup_document.becomes(Card::Annotation) キャストすると未保存のRelation(figuresなど)が失われる
        new_card = card.dup_document
        new_card.type = Card::Annotation.name
        new_card.save! # relation保存
        annotation = Card::Annotation.find(new_card.id)
        parent_state.annotations << annotation
        parent_state.save!
      end
      destroy
    end
    annotation.reload
  end
end

