# frozen_string_literal: true

describe CardCommentsController, type: :controller do
  describe 'POST #create' do
    subject { post :create, params: { card_id: card.id, body: body }, xhr: true }

    let(:card) { FactoryBot.create(:note_card) }
    let(:user) { FactoryBot.create(:user) }
    before { sign_in(user) }

    context 'with valid parameters' do
      let(:body) { 'valid' }

      it 'renders create with ok(200)' do
        is_expected.to have_http_status(:ok)
                  .and render_template :create
      end
      it { expect{ subject }.to change{ CardComment.count }.by(1) }
    end

    context 'with invalid parameters' do
      let(:body) { '' }

      it do
        is_expected.to have_http_status(400)
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body).to eq({ success: false, message: { body: ["can't be blank"] } })
      end
      it { expect{ subject }.not_to change{ CardComment.count } }
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: comment.id }, xhr: true }

    let!(:comment) { FactoryBot.create(:card_comment, user: user) }
    let(:user) { FactoryBot.create(:user) }

    before { sign_in(current_user) }

    context 'user can delete a comment' do
      let(:current_user) { user }

      it do
        is_expected.to have_http_status(:ok)
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body).to eq({ success: true })
      end
      it { expect{ subject }.to change{ CardComment.count }.by(-1) }
    end

    context 'user cannot delete a comment' do
      let(:current_user) { FactoryBot.create(:user) }

      it do
        is_expected.to have_http_status(400)
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body).to eq({ success: false })
      end
      it { expect{ subject }.not_to change{ CardComment.count } }
    end
  end
end
