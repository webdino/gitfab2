# == Schema Information
#
# Table name: cards
#
#  id               :integer          not null, primary key
#  annotatable_type :string(255)
#  description      :text(4294967295)
#  likes_count      :integer          default(0), not null
#  oldid            :string(255)
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

class Card::Annotation < Card
  # TODO: required: true を付けられるかどうか要検討
  belongs_to :annotatable, polymorphic: true
  acts_as_list scope: :annotatable

  scope :ordered_by_position, -> { order('position ASC') }

  class << self
    def updatable_columns
      super + [:position, :move_to]
    end
  end

  # AnnotationをState変換
  # 基底のCardクラスとしてdupした上でStateとしてrecipeの子に設定する
  def to_state!(recipe)
    state = nil
    transaction do
      Card.uncached do
        card = self.class.lock.find(id).tap{ |c| c.type = Card.name }.becomes(Card)
        # state = card.dup_document.becomes(Card::State) キャストすると未保存のRelation(figuresなど)が失われる
        new_card = card.dup_document
        new_card.type = Card::State.name
        new_card.save! # relation保存
        state = Card::State.find(new_card.id)
        recipe.states << state
        recipe.states.each.with_index(1) do |st, index|
          st.update_column :position, index
        end
        recipe.save!
      end
      destroy!
    end
    state.reload
  end
end
