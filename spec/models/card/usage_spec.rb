# frozen_string_literal: true

require 'spec_helper'

describe Card::Usage do
  it_behaves_like 'Card', :usage
  it_behaves_like 'Orderable', :usage
  it_behaves_like 'Orderable Scoped incrementation', [:usage], :project

  let(:usage) { FactoryGirl.build :usage }

  describe '#is_taggable?' do
    subject { usage.is_taggable? }
    it { is_expected.to be false }
  end
end
