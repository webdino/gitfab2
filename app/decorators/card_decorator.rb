module CardDecorator
  extend ActiveSupport::Concern
  included do
    def to_htmlclass
      _type.split(/::/).last.underscore
    end
  end
end
