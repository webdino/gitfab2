# == Schema Information
#
# Table name: recipes
#
#  id         :integer          not null, primary key
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

class Recipe < ActiveRecord::Base
  belongs_to :project, required: true
  has_many :states, ->{ order(:position) }, class_name: 'Card::State', dependent: :destroy, inverse_of: :recipe
  has_many :recipe_cards, ->{ order(:position) }, class_name: 'Card::RecipeCard', dependent: :destroy
  accepts_nested_attributes_for :states

  concerning :Draft do
    def generate_draft
      lines = []
      states.each do |state|
        lines << ActionController::Base.helpers.strip_tags(state.description)
      end
      lines.join("\n")
    end
  end

  def dup_document
    dup.tap do |doc|
      doc.states = states.map(&:dup_document)
    end
  end
end
