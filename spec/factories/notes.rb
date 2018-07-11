# frozen_string_literal: true
# == Schema Information
#
# Table name: notes
#
#  id         :integer          not null, primary key
#  num_cards  :integer          default(0), not null
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#
# Indexes
#
#  index_notes_num_cards   (num_cards)
#  index_notes_project_id  (project_id)
#
# Foreign Keys
#
#  fk_notes_project_id  (project_id => projects.id)
#

FactoryBot.define do
  factory :note do
    association :project, factory: :user_project
    num_cards 0
  end
end
