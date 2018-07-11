# frozen_string_literal: true

describe Tag do
  it_behaves_like 'DraftInterfaceTest', FactoryBot.create(:tag)

  let(:tag) { FactoryBot.create(:tag) }

  it { expect(tag).to be_respond_to(:name) }

  describe '#user' do
    it { expect(tag).to be_respond_to(:user) }
    it { expect(tag.user).to be_an_instance_of(User) }
  end

  describe '#taggable' do
    it { expect(tag).to be_respond_to(:taggable) }
    it { expect(tag.taggable.class).to be_include(Taggable) }
  end
end
