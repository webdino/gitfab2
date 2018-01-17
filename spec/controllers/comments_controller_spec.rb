require "spec_helper"

describe CommentsController, type: :controller do
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:project){FactoryGirl.create :user_project}

  describe "POST create" do
    context "with valid parameters" do
      before do
        note_card = project.note.note_cards.create
        sign_in user1
        xhr :post, :create, user_id: project.owner.to_param, project_id: project.id,
          note_card_id: note_card.id, comment: {body: "foo", user_id: user1.id}
      end
      it_behaves_like "success"
      it_behaves_like "render template", "create"
    end
    context "with invalid parameters" do
      before do
        note_card = project.note.note_cards.create
        sign_in user1
        xhr :post, :create, user_id: project.owner.to_param, project_id: project.id,
          note_card_id: note_card.id, comment: {body: "foo", user_id: "unkonwn_user_id"}
      end
      it{expect render_template 'error/failed', status: 400}
    end
  end

  describe "DELETE destroy" do
    before do
      note_card = project.note.note_cards.create
      comment = note_card.comments.create(user: user1)
      sign_in project.owner
      xhr :delete, :destroy, user_id: project.owner.to_param, project_id: project.id,
        note_card_id: note_card.id, id: comment.id
    end
    it_behaves_like "render template", "destroy"
  end
end
