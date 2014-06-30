module CardDecorator
  extend ActiveSupport::Concern
  included do
    def htmlclass
      _type.split(/::/).last.underscore
    end
  end
end
