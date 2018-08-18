# frozen_string_literal: true

describe NoteCardsController, type: :controller do
  render_views

  let(:project) { FactoryBot.create :user_project }
  let(:note_card) { project.note_cards.create title: 'foo', description: 'bar' }
  let(:new_note_card) { project.note_cards.build title: 'foo', description: 'bar' }
  let(:user) { project.owner }

  subject { response }

  describe 'GET new' do
    before { get :new, params: { owner_name: user, project_id: project }, xhr: true }
    it { is_expected.to render_template :new }
  end

  describe 'GET edit' do
    before { get :edit, params: { owner_name: user, project_id: project, id: note_card.id }, xhr: true }
    it { is_expected.to render_template :edit }
  end

  describe 'POST create' do
    context 'without attachments' do
      before do
        post :create, params: { owner_name: user, project_id: project, note_card: new_note_card.attributes }, xhr: true
        project.reload
      end
      it { is_expected.to render_template :create }
      it 'has 1 note_card' do
        expect(project.note_cards.size).to eq 1
      end
    end
    context 'with attachments' do
      before do
        post :create, params: {
          owner_name: user, project_id: project,
          note_card: new_note_card.attributes.merge(
            attachments_attributes: [FactoryBot.attributes_for(:attachment_material)]
          )
        }, xhr: true
        project.reload
      end
      it "has 1 attachment of kind 'material'" do
        note_card = project.note_cards.first
        aggregate_failures do
          expect(note_card.attachments.size).to eq 1
          expect(note_card.attachments.first.kind).to eq('material')
        end
      end
    end
    context 'with incorrect params' do
      before do
        # Card::NoteCardのtitle, descriptionにはバリデーションがあるが
        # card.js.coffeeのvalidateForm(event, is_note_card_form)でもalertを出している
        post :create,
          params: { owner_name: user, project_id: project, note_card: { title: '', description: '' } },
          xhr: true
      end
      it do
        aggregate_failures do
          is_expected.to have_http_status(400)
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
        end
      end
    end
  end

  describe 'PATCH update' do
    context 'with correct params' do
      let(:title_to_change) { '_foo' }
      let(:description_to_change) { '_bar' }

      context 'with a title only' do
        before do
          patch :update,
            params: { owner_name: user, project_id: project, id: note_card.id, note_card: { title: title_to_change } },
            xhr: true
          note_card.reload
        end
        it { is_expected.to render_template :update }
        it { expect(project.note_cards.first.title).to eq title_to_change }
      end
      context 'with a title and a description' do
        before do
          patch :update,
            params: {
              owner_name: user, project_id: project, id: note_card.id,
              note_card: { title: title_to_change, description: description_to_change }
            },
            xhr: true
          note_card.reload
        end
        it { is_expected.to render_template :update }
        it 'should change both a title and a description' do
          aggregate_failures do
            note_card = project.note_cards.first
            expect(note_card.title).to eq title_to_change
            expect(note_card.description).to eq description_to_change
          end
        end
      end
    end

    context 'with incorrect params' do
      before do
        # Card::NoteCardのtitle, descriptionにはバリデーションがあるが
        # card.js.coffeeのvalidateForm(event, is_note_card_form)でもalertを出している
        patch :update,
          params: { owner_name: user, project_id: project, id: note_card.id, note_card: { title: '', description: '' } },
          xhr: true
      end
      it do
        aggregate_failures do
          is_expected.to have_http_status(400)
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: false })
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before do
      delete :destroy, params: { owner_name: user, project_id: project, id: note_card.id }, xhr: true
      project.reload
    end
    it { expect(JSON.parse(response.body, symbolize_names: true)).to eq({ success: true }) }
    it 'has 0 note_cards' do
      expect(project.note_cards.count).to eq 0
    end
  end
end
