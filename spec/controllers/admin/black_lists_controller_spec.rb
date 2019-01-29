RSpec.describe Admin::BlackListsController, type: :controller do
  let(:user) { FactoryBot.create(:user, authority: authority) }

  before { sign_in user }

  describe "GET #index" do
    subject { get :index }

    context "with authority" do
      let(:authority) { "admin" }
      it { is_expected.to be_successful }
    end

    context "without authority" do
      let(:authority) { nil }
      it { is_expected.to redirect_to root_path }
    end
  end

  describe "GET #show" do
    subject { get :show, params: { id: black_list.id } }
    let(:black_list) { FactoryBot.create(:black_list) }

    context "with authority" do
      let(:authority) { "admin" }
      it { is_expected.to be_successful }
    end

    context "without authority" do
      let(:authority) { nil }
      it { is_expected.to redirect_to root_path }
    end
  end

  describe "GET #new" do
    subject { get :new }

    context "with authority" do
      let(:authority) { "admin" }
      it { is_expected.to be_successful }
    end

    context "without authority" do
      let(:authority) { nil }
      it { is_expected.to redirect_to root_path }
    end
  end

  describe "POST #create" do
    subject { post :create, params: { black_list: black_list_params } }
    let(:black_list_params) {
      {
        project_id: FactoryBot.create(:project).id,
        reason: "不適切な表現が含まれるため"
      }
    }

    context "with authority" do
      let(:authority) { "admin" }

      context "with valid params" do
        it "creates a new BlackList" do
          expect{ subject }.to change(BlackList, :count).by(1)
        end
        it { is_expected.to redirect_to(admin_black_lists_url) }
      end

      context "with invalid params" do
        let(:black_list_params) {
          {
            project_id: nil,
            reason: ""
          }
        }

        it "returns a success response (i.e. to display the 'new' template)" do
          is_expected.to be_successful
        end
      end
    end

    context "without authority" do
      let(:authority) { nil }
      it { is_expected.to redirect_to root_path }
    end
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, params: { id: black_list.id } }
    let!(:black_list) { FactoryBot.create(:black_list) }

    context "with authority" do
      let(:authority) { "admin" }

      it "destroys the requested admin_black_list" do
        expect{ subject }.to change(BlackList, :count).by(-1)
      end
      it { is_expected.to redirect_to(admin_black_lists_url) }
    end

    context "without authority" do
      let(:authority) { nil }
      it { is_expected.to redirect_to root_path }
    end
  end

end
