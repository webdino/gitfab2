# == Schema Information
#
# Table name: cards
#
#  id            :integer          not null, primary key
#  description   :text(4294967295)
#  position      :integer          default(0), not null
#  title         :string(255)
#  type          :string(255)      not null
#  created_at    :datetime
#  updated_at    :datetime
#  annotation_id :integer
#  project_id    :integer
#  recipe_id     :integer
#
# Indexes
#
#  index_cards_on_annotation_id  (annotation_id)
#  index_cards_project_id        (project_id)
#  index_cards_recipe_id         (recipe_id)
#
# Foreign Keys
#
#  fk_cards_project_id  (project_id => projects.id)
#  fk_cards_recipe_id   (recipe_id => recipes.id)
#

class Card::RecipeCard < Card
  include Annotatable
  belongs_to :recipe
  acts_as_list scope: :recipe

  scope :ordered_by_position, -> { order('position ASC') }

  class << self
    def updatable_columns
      super + [:position, :move_to]
    end
  end
end
