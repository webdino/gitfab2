
FactoryGirl.define do
  factory :attachment, class: Attachment do
    title 'Attachment'
    content File.open(File.join Rails.root, '/spec/assets/images/image.jpg')
  end

  factory :attachment_material, parent: :attachment do
    title 'Material'
    kind 'material'
  end

  factory :attachment_tool, parent: :attachment do
    title 'Tool'
    kind 'tool'
  end
end
