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
      it{is_expected.to render_template :create}
      it{expect(project.note).to have(1).note_cards}
    end
    context "with attachments" do
      before do
        xhr :post, :create, user_id: user, project_id: project,
          note_card: new_note_card.attributes.merge({
            attachments_attributes: [FactoryGirl.attributes_for(:attachment_material)]})
        project.reload
      end
      it{expect(project.note.note_cards.first).to have(1).attachments}
      it do
        expect(project.note.note_cards.first.attachments.first.kind)
          .to eq('material')
      end
    end
    xcontext "with incorrect params" do
      before do
        # TODO: Card::NoteCardのtitle, descriptionにはバリデーション無い
        # card.js.coffeeのvalidateForm(event, is_note_card_form)で制御している
        xhr :post, :create, user_id: user, project_id: project, note_card: { title: "", description: "" }
      end
      it{ is_expected.to render_template 'errors/failed'}
      it { is_expected.to have_http_status(400)}
    end
  end

  describe "PATCH update" do
    context "with correct params" do
      let(:title_to_change){"_foo"}
      before do
        xhr :patch, :update, user_id: user, project_id: project,
          id: note_card.id, note_card: {title: title_to_change}
        note_card.reload
      end
      it{is_expected.to render_template :update}
      it{expect(project.note.note_cards.first.title).to eq title_to_change}
    end

    xcontext "with incorrect params" do
      before do
        # TODO: Card::NoteCardのtitle, descriptionにはバリデーション無い
        # card.js.coffeeのvalidateForm(event, is_note_card_form)で制御している
        xhr :patch, :update, user_id: user, project_id: project,
          id: note_card.id, note_card: {title: "", description: ""}
      end
      it { is_expected.to render_template 'errors/failed' }
      it { is_expected.to have_http_status(400) }
    end
  end

  describe "DELETE destroy" do
    before do
      xhr :delete, :destroy, owner_name: user, project_id: project,
        id: note_card.id
      project.reload
    end
    it{is_expected.to render_template :destroy}
    it{expect(project.note.note_cards).to have(0).note_cards}
  end
end
