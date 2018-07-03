# frozen_string_literal: true

describe Card::State do
  it_behaves_like 'Annotable', :state
  it_behaves_like 'Card', :state
  it_behaves_like 'Orderable', :state
  it_behaves_like 'Orderable Scoped incrementation', [:state], :recipe

  describe '.ordered_by_position' do
    let(:state) { FactoryBot.build :state }
    it { expect(Card::State).to be_respond_to(:ordered_by_position) }
  end

  describe '#is_taggable?' do
    let(:state) { FactoryBot.build :state }
    subject { state.is_taggable? }
    it { is_expected.to be false }
  end

  describe '#to_annotation!(parent_state)' do
    let!(:state) { FactoryBot.create(:state) }
    let!(:parent_state) { FactoryBot.create(:state) }
    describe '内容を維持してAnnotationとして作りなおす' do
      subject!(:new_annotation) { state.to_annotation!(parent_state) }
      it { expect(new_annotation).to be_an_instance_of(Card::Annotation) }
      it { expect(new_annotation.title).to eq(state.title) }
      it { expect(state).to be_destroyed }
    end
    it 'parent_stateのannotationsに追加する' do
      expect do
        state.to_annotation!(parent_state)
      end.to change { parent_state.annotations.reload.count }
    end
  end
end
