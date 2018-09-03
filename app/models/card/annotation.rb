# == Schema Information
#
# Table name: cards
#
#  id          :integer          not null, primary key
#  description :text(4294967295)
#  position    :integer          default(0), not null
#  title       :string(255)
#  type        :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  project_id  :integer
#  state_id    :integer
#
# Indexes
#
#  index_cards_on_state_id  (state_id)
#  index_cards_project_id   (project_id)
#
# Foreign Keys
#
#  fk_cards_project_id  (project_id => projects.id)
#

class Card::Annotation < Card
  belongs_to :state, class_name: "Card::State", foreign_key: :state_id
  acts_as_list scope: :state

  scope :ordered_by_position, -> { order(:position) }

  class << self
    def updatable_columns
      super + [:position]
    end
  end

  def project
    state.project
  end

  def to_state!(project)
    update!(
      type: Card::State.name,
      project_id: project.id,
      position: Card::State.where(project_id: project.id).maximum(:position).to_i + 1
    )
    Card::State.find(id)
  end
end
