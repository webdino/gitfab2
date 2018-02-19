# frozen_string_literal: true

require 'spec_helper'

describe Feature do
  it { expect(Feature).to be_respond_to(:projects) }
  it { expect(Feature).to be_respond_to(:groups) }
  it { expect(Feature).to be_respond_to(:users) }

  describe 'attributes' do
    let(:feature) { FactoryGirl.create(:feature) }
    it { expect(feature).to be_respond_to(:name) }
    it { expect(feature).to be_respond_to(:class_name) }
    it { expect(feature).to be_respond_to(:category) }
  end

  describe '#featured_items' do
    let(:feature) { FactoryGirl.create(:feature) }
    it { expect(feature).to be_respond_to(:featured_items) }
    it { expect(feature.featured_items.build).to be_an_instance_of(FeaturedItem) }
  end
end
