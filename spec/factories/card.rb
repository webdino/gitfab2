FactoryGirl.define do
  factory :card do
    _type Card.name
    description "description"
  end

  factory :note_card, class: Card::NoteCard do
    _type Card::NoteCard.name
  end

  factory :annotation, class: Card::Annotation do
    _type Card::Annotation.name
  end

  factory :state, class: Card::State do
    _type Card::State.name
  end

  factory :usage, class: Card::Usage do
    _type Card::Usage.name
  end


end
