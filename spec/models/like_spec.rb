# frozen_string_literal: true

describe Like do
  it_behaves_like 'Contributable', :like

  let(:like) { FactoryBot.create(:like) }

  it '#liker' do
    expect(like.liker.class).to be_include(Liker)
  end

  it '#likable' do
    expect(like.likable.class).to be_include(Likable)
  end
end
