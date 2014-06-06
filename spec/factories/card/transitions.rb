FactoryGirl.define do
  factory :transition, class: Card::Transition do
    _type Card::Transition.name
    description "transition!"
  end
end
