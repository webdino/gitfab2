require "spec_helper"

describe Card::State do
  it_behaves_like 'Card', :state
  it_behaves_like 'Orderable', :state
  it_behaves_like 'Orderable Scoped incrementation', [:state], :recipe

  let(:state){FactoryGirl.build :state}

  describe '.ordered_by_position' do
    it { expect(Card::State).to be_respond_to(:ordered_by_position) }
  end

  describe "#is_taggable?" do
    subject{state.is_taggable?}
    it{should be false}
  end
end
