# frozen_string_literal: true

# == Schema Information
#
# Table name: recipes
#
#  id         :integer          not null, primary key
#  oldid      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#
# Indexes
#
#  index_recipes_project_id  (project_id)
#
# Foreign Keys
#
#  fk_recipes_project_id  (project_id => projects.id)
#


FactoryBot.define do
  factory :recipe do
    association :project, factory: :user_project
  end
end
