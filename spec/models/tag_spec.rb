# frozen_string_literal: true

require 'spec_helper'

describe Tag do
  let(:tag) { FactoryGirl.create(:tag) }

  it { expect(tag).to be_respond_to(:name) }

  describe '#user' do
    it { expect(tag).to be_respond_to(:user) }
    it { expect(tag.user).to be_an_instance_of(User) }
  end

  describe '#taggable' do
    it { expect(tag).to be_respond_to(:taggable) }
    it { expect(tag.taggable.class).to be_include(Taggable) }
  end

  describe '#generate_draft' do
    tag = FactoryGirl.create(:tag)
    it_behaves_like 'DraftGenerator', tag
  end
end
