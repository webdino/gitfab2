require "spec_helper"

describe CommentsController, type: :controller do
  disconnect_sunspot
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:project){FactoryGirl.create :user_project}

  describe "POST create" do
    before do
      note_card = project.note.note_cards.create
      sign_in user1
      xhr :post, :create, user_id: project.owner.id, project_id: project.id,
        note_card_id: note_card.id, comment: {body: "foo", user_id: user1.id}
    end
    it_behaves_like "success"
    it_behaves_like "render template", "create"
  end

  describe "DELETE destroy" do
    before do
      note_card = project.note.note_cards.create
      comment = note_card.comments.create
      xhr :delete, :destroy, user_id: project.owner.id, project_id: project.id,
        note_card_id: note_card.id, id: comment.id
    end
    it_behaves_like "render template", "destroy"
  end
end
