# frozen_string_literal: true

require 'spec_helper'

describe Figure do
  describe '#dup_document' do
    shared_examples_for '複製を返す' do |*factory|
      let(:figure) { FactoryBot.create(*factory) }
      subject(:dupped_document) { figure.dup_document }

      it '自身の複製を返すこと' do
        expect(dupped_document).to be_an_instance_of(Figure)
        expect(dupped_document.id).to_not eq(figure.id)
      end

      it '同じlink' do
        expect(dupped_document.link).to eq(figure.link)
      end
    end

    context 'contentなしのとき' do
      it_behaves_like '複製を返す', :link_figure
    end

    context 'contentありのとき' do
      it_behaves_like '複製を返す', :content_figure

      it 'contentを複製すること' do
        figure = FactoryBot.create(:content_figure)
        dupped_document = figure.dup_document
        expect(dupped_document).to be_content_changed
        expect(dupped_document.content.filename).to eq(figure.content.filename)
      end
    end
  end
end
