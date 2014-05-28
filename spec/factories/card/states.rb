FactoryGirl.define do
  factory :state, class: Card::State do
    _type Card::State.name
    description "state!"
  end
end
