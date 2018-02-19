# frozen_string_literal: true

require 'spec_helper'

describe FeaturedItem do
  describe 'attributes' do
    let(:featured_item) { FactoryGirl.create(:featured_item) }
    it { expect(featured_item).to be_respond_to(:target_object_id) }
    it { expect(featured_item).to be_respond_to(:url) }
  end

  describe '#feature' do
    let(:featured_item) { FactoryGirl.create(:featured_item) }
    it { expect(featured_item).to be_respond_to(:feature) }
    it { expect(featured_item.feature).to be_an_instance_of(Feature) }
  end
end
