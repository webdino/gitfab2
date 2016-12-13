module ProjectOwner
  extend ActiveSupport::Concern
  included do
    has_many :projects, as: :owner
    scope :ordered_by_name, -> { order('name ASC') }
  end
end
