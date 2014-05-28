module ProjectOwner
  extend ActiveSupport::Concern
  included do
    has_many :projects, as: :owner
  end
end
