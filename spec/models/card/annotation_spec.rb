require "spec_helper"

describe Card::Annotation do
  it_behaves_like 'Card', :annotation
  it_behaves_like 'Orderable', :annotation
  it_behaves_like 'Orderable Scoped incrementation', [:annotation], :annotatable

  let(:annotation){FactoryGirl.build :annotation}

  describe '.ordered_by_position' do
    it { expect(Card::Annotation).to be_respond_to(:ordered_by_position) }
  end

  describe "#is_taggable?" do
    subject{annotation.is_taggable?}
    it{should be false}
  end
end
