# == Schema Information
#
# Table name: cards
#
#  id               :integer          not null, primary key
#  annotatable_type :string(255)
#  description      :text(4294967295)
#  oldid            :string(255)
#  position         :integer          default(0), not null
#  title            :string(255)
#  type             :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  annotatable_id   :integer
#  note_id          :integer
#  project_id       :integer
#  recipe_id        :integer
#
# Indexes
#
#  index_cards_annotatable  (annotatable_type,annotatable_id)
#  index_cards_note_id      (note_id)
#  index_cards_project_id   (project_id)
#  index_cards_recipe_id    (recipe_id)
#
# Foreign Keys
#
#  fk_cards_note_id     (note_id => notes.id)
#  fk_cards_project_id  (project_id => projects.id)
#  fk_cards_recipe_id   (recipe_id => recipes.id)
#

class Card::Transition < Card::RecipeCard
end
