# frozen_string_literal: true

FactoryBot.define do
  factory :attachment do
    title 'Attachment'
    content { File.open(Rails.root.join('spec', 'fixtures', 'images', 'image.jpg')) }
    association :attachable, factory: :card
  end

  factory :attachment_material, parent: :attachment do
    title 'Material'
    kind 'material'
  end
end
