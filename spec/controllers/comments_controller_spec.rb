require "spec_helper"

describe CommentsController, type: :controller do
  render_views

  let(:user1){FactoryGirl.create :user}
  let(:project){FactoryGirl.create :user_project}

  subject { response }

  describe "POST create" do
    context "with valid parameters" do
      before do
        note_card = FactoryGirl.create(:note_card, note: project.note)

        sign_in user1
        xhr :post, :create, user_id: project.owner.to_param, project_id: project.id,
          note_card_id: note_card.id, comment: { body: "foo" }
      end
      it 'should render create with ok(200)' do
        aggregate_failures do
          is_expected.to have_http_status(:ok)
          is_expected.to render_template :create
        end
      end
    end
    context "with invalid parameters" do
      before do
        note_card = FactoryGirl.create(:note_card, note: project.note)

        sign_in user1
        xhr :post, :create, user_id: project.owner.to_param, project_id: project.id,
          note_card_id: note_card.id, comment: { body: '' }
      end
      it "should render 'failed' with 400" do
        aggregate_failures do
          is_expected.to render_template 'failed'
          is_expected.to have_http_status(400)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before do
      note_card = FactoryGirl.create(:note_card, note: project.note)
      comment = FactoryGirl.create(:comment, user: user1, commentable: note_card)
      sign_in project.owner
      xhr :delete, :destroy, user_id: project.owner.to_param, project_id: project.id,
        note_card_id: note_card.id, id: comment.id
      note_card.reload
    end
    it { is_expected.to render_template :destroy }
  end
end
