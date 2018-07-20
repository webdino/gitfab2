# frozen_string_literal: true

describe Card::Annotation do
  it_behaves_like 'Card', :annotation
  it_behaves_like 'Orderable', :annotation
  it_behaves_like 'Orderable Scoped incrementation', [:annotation], :annotation_id

  describe '.ordered_by_position' do
    let(:annotation) { FactoryBot.create(:annotation) }
    it { expect(Card::Annotation).to be_respond_to(:ordered_by_position) }
  end

  describe '#to_state!' do
    subject { annotation.to_state!(recipe) }

    let!(:annotation) { FactoryBot.create(:annotation) }
    let!(:recipe) { FactoryBot.create(:recipe) }

    it { is_expected.to be_an_instance_of(Card::State) }
    it do
      expect{ subject }.to change{ annotation.type }.from(Card::Annotation.name).to(Card::State.name)
                      .and change{ recipe.states.count }.by(1)
                      .and change{ Card::Annotation.count }.by(-1)
    end

    describe 'position' do
      before { FactoryBot.create_list(:state, state_count, recipe: recipe) }
      let(:state_count) { 2 }
      it { expect(subject.position).to eq state_count + 1 }
    end
  end
end
