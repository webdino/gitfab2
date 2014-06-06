module Searchable
  extend ActiveSupport::Concern
  included do
    include Sunspot::Mongoid2
    cattr_accessor :searchable_fields
  end

  module ClassMethods
    def searchable_field *args
      self.searchable_fields ||= Array.new
      self.searchable_fields << args.first
      field *args
    end
  end
end
