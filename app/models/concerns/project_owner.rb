module ProjectOwner
  extend ActiveSupport::Concern
  included do
    has_many :projects, as: :owner
    field :projects_count, type: Integer
    scope :ordered_by_name, -> { order('name ASC') }
  end
end
