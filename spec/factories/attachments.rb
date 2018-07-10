# frozen_string_literal: true

# == Schema Information
#
# Table name: attachments
#
#  id              :integer          not null, primary key
#  attachable_type :string(255)      not null
#  content         :string(255)
#  content_tmp     :string(255)
#  description     :string(255)
#  kind            :string(255)
#  link            :text(65535)
#  oldid           :string(255)
#  title           :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  attachable_id   :integer          not null
#  markup_id       :string(255)
#
# Indexes
#
#  index_attachments_attachable  (attachable_type,attachable_id)
#


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
