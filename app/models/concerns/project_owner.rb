module ProjectOwner
  extend ActiveSupport::Concern
  included do
    has_many :projects, as: :owner do
      def soft_destroy_all!
        transaction do
          active
            .includes(:owner, :states, :tags, :likes, :note_cards, :usages, :project_comments, :figures, :collaborations)
            .find_each(&:soft_destroy!)
        end
      end
    end
    scope :ordered_by_name, -> { order(:name) }
  end

  def update_projects_count
    update_column(:projects_count, projects.published.count)
  end
end
