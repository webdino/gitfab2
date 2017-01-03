class Card::Annotation < Card
  belongs_to :annotatable, polymorphic: true
  acts_as_list

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
