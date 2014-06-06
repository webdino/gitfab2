FactoryGirl.define do
  factory :annotation, class: Card::Annotation do
    _type Card::Annotation.name
    description "annotation!"
  end
end
