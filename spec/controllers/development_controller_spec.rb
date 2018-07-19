# frozen_string_literal: true

describe DevelopmentController, type: :controller do
  render_views

  let(:user) { FactoryBot.create :user }
  let(:other) { FactoryBot.create :user }

  describe 'POST su' do
    before do
      sign_in user
      request.env['HTTP_REFERER'] = '/foo.html'
      post :su, params: { user_id: other.id }
    end
    it { expect(response).to redirect_to '/foo.html' }
  end
end
