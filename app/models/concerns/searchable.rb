module Searchable
  extend ActiveSupport::Concern
  included do
    cattr_accessor :searchable_fields
  end

  module ClassMethods
    def searchable_field(*args)
      self.searchable_fields ||= []
      self.searchable_fields << args.first
    end
  end
end
