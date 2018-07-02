# NOTE: frozen_string_literalをtrueにすると
# 複製の際にcan't modify frozen String

FactoryBot.define do
  factory :figure do
    # TODO: figurable はnil になりうるのかどうか要確認
    figurable nil
    link nil

    after(:build) do |figure|
      # TODO: figurable はnil になりうるのかどうか要確認
      figurable = figure.figurable || FactoryBot.build(:user_project)
      figurable.figures << figure
      figurable.save!
    end

    factory :link_figure do
      sequence(:link) { |n| "http://test.host/link/#{n}.png" }
    end

    factory :content_figure do
      content do
        ActionDispatch::Http::UploadedFile.new(
          filename: 'figure.png',
          type: 'image/png',
          tempfile: File.open(Rails.root.join('spec', 'files', 'figure.png'))
        )
      end
    end
  end
end
