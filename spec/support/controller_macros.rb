# frozen_string_literal: true

# controller spec でもN+1検知できるようにする
# https://github.com/flyerhzm/bullet/issues/120#issuecomment-64226287
module ControllerMacros
  module InstanceMethods
    %w[get post put patch delete options head].each do |method|
      define_method method do |*args|
        Bullet.profile do
          super(*args)
        end
      end
    end
  end
end
