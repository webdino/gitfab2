# frozen_string_literal: true

describe OwnersController, type: :controller do
  describe "GET #index" do
    subject { get :index, format: :json }
    it { is_expected.to be_successful }
  end

  describe "GET #show" do
    subject { get :show, params: { owner_name: user.slug } }
    let(:user) { FactoryBot.create(:user) }
    it { is_expected.to be_successful }
  end
end
