FactoryGirl.define do
  factory :card do
    _type Card.name
    description "description"
  end

  factory :note_card, class: Card::NoteCard do
    _type Card::NoteCard.name
    description "description"
  end

  factory :annotation, class: Card::Annotation do
    _type Card::Annotation.name
    description "description"
  end

  factory :state, class: Card::State do
    _type Card::State.name
    description "description"
  end

  factory :usage, class: Card::Usage do
    _type Card::Usage.name
    description "description"
  end
end
