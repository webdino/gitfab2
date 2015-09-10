module Contributor
  extend ActiveSupport::Concern
  included do
    def contributed?(contributable)
      contributable.contributions.where(contributor: self).exists?
    end
  end
end
