class Sanitize
  module Config
    CARD = {
      :elements => %w[
        a br li ol ul u i b div
      ],

      :attributes => {
        :all => %w[class id],
        'a'  => %w[href target],
      },

      :protocols => {
        'a'  => {'href' => ['http', 'https', 'mailto', :relative]},
      }
    }
  end
end
