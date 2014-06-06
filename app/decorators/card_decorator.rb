module CardDecorator
  extend ActiveSupport::Concern
  included do
    def dc_type
      _type.split(/::/).last
    end
  end
end
