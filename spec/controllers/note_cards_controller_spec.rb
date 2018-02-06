require "spec_helper"

describe NoteCardsController, type: :controller do
  render_views

  let(:project){FactoryGirl.create :user_project}
  let(:note_card){project.note.note_cards.create title: "foo", description: "bar"}
  let(:new_note_card){project.note.note_cards.build title: "foo", description: "bar"}
  let(:user){project.owner}

  subject{response}

  describe "GET new" do
    before do
      xhr :get, :new, owner_name: user, project_id: project
    end
    it{is_expected.to render_template :new}
  end

  describe "GET edit" do
    before do
      xhr :get, :edit, owner_name: user, project_id: project,
        id: note_card.id
    end
    it{is_expected.to render_template :edit}
  end

  describe "POST create" do
    context "without attachments" do
      before do
        xhr :post, :create, user_id: user, project_id: project,
          note_card: new_note_card.attributes
        project.reload
      end
      it{ is_expected.to render_template :create }
      it 'has 1 note_card' do
        expect(project.note.note_cards.size).to eq 1
      end
    end
    context "with attachments" do
      before do
        xhr :post, :create, user_id: user, project_id: project,
          note_card: new_note_card.attributes.merge({
            attachments_attributes: [FactoryGirl.attributes_for(:attachment_material)]})
        project.reload
      end
      it "has 1 attachment of kind 'material'" do
        note_card = project.note.note_cards.first
        aggregate_failures do
          expect(note_card.attachments.size).to eq 1
          expect(note_card.attachments.first.kind).to eq('material')
        end
      end
    end
    context "with incorrect params" do
      before do
        # Card::NoteCardのtitle, descriptionにはバリデーションがあるが
        # card.js.coffeeのvalidateForm(event, is_note_card_form)でもalertを出している
        xhr :post, :create, user_id: user, project_id: project, note_card: { title: '', description: '' }
      end
      it "should render 'errors/failed' with 400" do
        aggregate_failures do
          is_expected.to render_template 'errors/failed'
          is_expected.to have_http_status(400)
        end
      end
    end
  end

  describe "PATCH update" do
    context "with correct params" do
      let(:title_to_change) { "_foo" }
      let(:description_to_change) { "_bar" }

      context 'with a title only' do
        before do
          xhr :patch, :update, user_id: user, project_id: project,
            id: note_card.id, note_card: {title: title_to_change}
          note_card.reload
        end
        it{ is_expected.to render_template :update }
        it{ expect(project.note.note_cards.first.title).to eq title_to_change }
      end
      context 'with a title and a description' do
        before do
          xhr :patch, :update, user_id: user, project_id: project,
            id: note_card.id, note_card: { title: title_to_change, description: description_to_change }
          note_card.reload
        end
        it{ is_expected.to render_template :update }
        it 'should change both a title and a description' do
          aggregate_failures do
            note_card = project.note.note_cards.first
            expect(note_card.title).to eq title_to_change
            expect(note_card.description).to eq description_to_change
          end
        end
      end
    end

    context "with incorrect params" do
      before do
        # Card::NoteCardのtitle, descriptionにはバリデーションがあるが
        # card.js.coffeeのvalidateForm(event, is_note_card_form)でもalertを出している
        xhr :patch, :update, user_id: user, project_id: project,
          id: note_card.id, note_card: { title: '', description: '' }
      end
      it "should render 'errors/failed' with 400" do
        aggregate_failures do
          is_expected.to render_template 'errors/failed'
          is_expected.to have_http_status(400)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before do
      xhr :delete, :destroy, owner_name: user, project_id: project,
        id: note_card.id
      project.reload
    end
    it{is_expected.to render_template :destroy}
    it 'has 0 note_cards' do
      expect(project.note.note_cards.size).to eq 0
    end
  end
end
