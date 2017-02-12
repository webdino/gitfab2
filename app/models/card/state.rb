class Card::State < Card
  include Annotatable
  belongs_to :recipe
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

