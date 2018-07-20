# frozen_string_literal: true

describe Card::State do
  it_behaves_like 'Annotatable', :state
  it_behaves_like 'Card', :state
  it_behaves_like 'Orderable', :state
  it_behaves_like 'Orderable Scoped incrementation', [:state], :recipe

  describe '.ordered_by_position' do
    let(:state) { FactoryBot.build :state }
    it { expect(Card::State).to be_respond_to(:ordered_by_position) }
  end

  describe '#to_annotation!' do
    subject { state.to_annotation!(parent_state) }

    let(:state) { FactoryBot.create(:state) }
    let(:parent_state) { FactoryBot.create(:state) }
    let(:recipe) { state.recipe }

    it { is_expected.to be_an_instance_of(Card::Annotation) }
    it do
      expect{ subject }.to change{ state.type }.from(Card::State.name).to(Card::Annotation.name)
                      .and change{ parent_state.annotations.count }.by(1)
                      .and change{ recipe.states.count }.by(-1)
    end
  end
end
