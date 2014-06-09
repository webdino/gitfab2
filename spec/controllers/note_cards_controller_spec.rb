require "spec_helper"

describe NoteCardsController, type: :controller do
  disconnect_sunspot
  render_views

  let(:project){FactoryGirl.create :user_project}
  let(:note_card){project.note.note_cards.create title: "foo", description: "bar"}
  let(:new_note_card){project.note.note_cards.build title: "foo", description: "bar"}
  let(:user){project.owner}

  subject{response}

  describe "GET new" do
    before do
      xhr :get, :new, user_id: user.id, project_id: project.id
    end
    it{should render_template :new}
  end

  describe "GET edit" do
    before do
      xhr :get, :edit, user_id: user.id, project_id: project.id,
        id: note_card.id
    end
    it{should render_template :edit}
  end

  describe "POST create" do
    context "without attachments" do
      before do
        xhr :post, :create, user_id: user.id, project_id: project.id,
          note_card: new_note_card.attributes
        project.reload
      end
      it{should render_template :create}
      it{expect(project.note).to have(1).note_cards}
    end
    context "with attachments" do
      before do
        xhr :post, :create, user_id: user.id, project_id: project.id,
          note_card: new_note_card.attributes.merge({
            attachments_attributes: [{content: UploadFileHelper.upload_file}]})
        project.reload
      end
      it{should render_template :create}
      it{expect(project.note).to have(1).note_cards}
      it{expect(project.note.note_cards.first).to have(1).attachments}
    end
  end

  describe "PATCH update" do
    let(:title_to_change){"_foo"}
    before do
      xhr :patch, :update, user_id: user.id, project_id: project.id,
        id: note_card.id, note_card: {title: title_to_change}
      note_card.reload
    end
    it{should render_template :update}
    it{expect(project.note.note_cards.first.title).to eq title_to_change}
  end

  describe "DELETE destroy" do
    before do
      xhr :delete, :destroy, user_id: user.id, project_id: project.id,
        id: note_card.id
      project.reload
    end
    it{should render_template :destroy}
    it{expect(project.note.note_cards).to have(0).note_cards}
  end
end
