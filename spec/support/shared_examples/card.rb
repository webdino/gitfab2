# frozen_string_literal: true

shared_examples 'Card' do |*factory_args|
  let(:card) { FactoryBot.create(*factory_args) }

  it_behaves_like 'Figurable', *factory_args

  describe '#dup_document' do
    it do
      expect(card).to be_respond_to(:dup_document)
    end

    subject(:dupped_card) { card.dup_document }

    it '自身の複製を返すこと' do
      expect(dupped_card).to be_an_instance_of(card.class)
      expect(dupped_card.id).to_not eq(card.id)
    end

    it { expect(dupped_card.title).to eq(card.title) }
    it { expect(dupped_card.description).to eq(card.description) }

    it 'figures を複製すること' do
      card.figures << FactoryBot.build(:link_figure)
      card.figures << FactoryBot.build(:link_figure)
      card.save!

      expect(dupped_card.figures).to_not eq(card.figures)
      expect(dupped_card.figures.size).to eq(card.figures.size)
    end

    it 'attachments を複製すること' do
      card.attachments << FactoryBot.build(:attachment)
      card.attachments << FactoryBot.build(:attachment)
      card.save!

      expect(dupped_card.attachments).to_not eq(card.attachments)
      expect(dupped_card.attachments.size).to eq(card.attachments.size)
    end
  end

  describe '#project' do
    it { expect(card.project).to be_kind_of(Project) }
  end
end
