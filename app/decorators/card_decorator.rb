module CardDecorator
  extend ActiveSupport::Concern
  included do
    def htmlclass
      type.split(/::/).last.underscore
    end
  end
end
