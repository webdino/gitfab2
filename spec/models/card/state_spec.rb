# frozen_string_literal: true

describe Card::State do
  it_behaves_like 'Card', :state
  it_behaves_like 'Orderable', :state
  it_behaves_like 'Orderable Scoped incrementation', [:state], :project

  describe '.ordered_by_position' do
    let(:state) { FactoryBot.build :state }
    it { expect(Card::State).to be_respond_to(:ordered_by_position) }
  end

  describe '#to_annotation!' do
    subject { state.to_annotation!(parent_state) }

    let(:state) { FactoryBot.create(:state) }
    let(:parent_state) { FactoryBot.create(:state) }
    let(:project) { state.project }

    it { is_expected.to be_an_instance_of(Card::Annotation) }
    it do
      expect{ subject }.to change{ state.type }.from(Card::State.name).to(Card::Annotation.name)
                      .and change{ parent_state.annotations.count }.by(1)
                      .and change{ project.states_count }.by(-1)
    end
  end

  describe '#dup_document' do
    subject(:dupped_card) do
      card.dup_document.tap(&:save!)
    end

    let(:card) do
      FactoryBot.create(:state) do |state|
        FactoryBot.create_list(:annotation, annotation_count, state: state)
      end
    end
    let(:annotation_count) { 5 }

    it '数を維持すること' do
      expect(dupped_card.annotations.count).to eq(annotation_count)
    end
    it '順番・内容を維持すること' do
      card.annotations.to_a.shuffle.each.with_index(1) do |annotation, i|
        annotation.update_column(:position, i)
      end
      card.annotations.reload

      actual   = Card::Annotation.where(id: dupped_card.annotations.pluck(:id)).order(:position).map(&:title)
      expected = Card::Annotation.where(id: card       .annotations.pluck(:id)).order(:position).map(&:title)
      expect(actual).to eq(expected)
    end
    it '複製であること' do
      expect(dupped_card.annotations.map(&:id)).to_not eq(card.annotations.map(&:id))
    end
  end
end
