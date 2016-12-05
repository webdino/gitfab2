module MongoidStubbable
  extend ActiveSupport::Concern

  class Deprecator
    def deprecation_warning(method_name, message, _caller_backtrace = nil)
      message = "#{method_name} is deprecated and will be removed | #{message}"
      Kernel.warn message
    end
  end

  module ClassMethods
    def embeds_many(relation_name, *_options)
      has_many relation_name
    end
    deprecate :embeds_many, deprecator: MongoidStubbable::Deprecator.new

    def embeds_one(relation_name, *_options)
      has_one relation_name
    end
    deprecate :embeds_one, deprecator: MongoidStubbable::Deprecator.new

    def embedded_in(relation_name, options={})
      belongs_to relation_name, options
    end
    deprecate :embedded_in, deprecator: MongoidStubbable::Deprecator.new

    [
      :field,
      :index,

    ].each do |method_name|
      class_eval <<"CODE"
       def #{method_name}(*args); end
       deprecate :#{method_name}, deprecator: MongoidStubbable::Deprecator.new
CODE
    end
  end

end
