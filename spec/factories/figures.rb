# == Schema Information
#
# Table name: figures
#
#  id             :integer          not null, primary key
#  content        :string(255)
#  figurable_type :string(255)
#  link           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  figurable_id   :integer
#
# Indexes
#
#  index_figures_figurable  (figurable_type,figurable_id)
#

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
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec', 'fixtures', 'images', 'figure.png'),
          'image/png'
        )
      end
    end
  end
end
