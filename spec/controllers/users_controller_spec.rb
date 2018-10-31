# frozen_string_literal: true

describe UsersController, type: :controller do
  describe 'GET index' do
    subject { get :index, format: :json }
    it { is_expected.to be_successful }

    context 'when active and deleted users' do
      let!(:active) { FactoryBot.create(:user, is_deleted: false) }
      let!(:deleted) { FactoryBot.create(:user, is_deleted: true) }

      it 'fetches active users only' do
        subject
        expect(assigns(:users)).to eq [active]
      end
    end
  end

  describe 'GET new' do
    subject { get :new, params: params }
    let(:params) { {} }

    it { is_expected.to be_successful }

    context 'on oauth sign up' do
      let(:params) { { token: identity.encrypted_id } }
      let(:identity) { FactoryBot.create(:identity, user: nil) }
      it do
        expect(Identity).to receive(:find_by_encrypted_id).and_call_original
        subject
      end
    end

    context 'on password sign up' do
      let(:params) { {} }
      it do
        expect(User::PasswordAuth).to receive(:new)
        subject
      end
    end
  end

  describe 'POST create' do
    subject { post :create, params: { user: user_params } }

    context 'on oauth sign up' do
      let(:identity) { FactoryBot.create(:identity, user: nil) }
      let(:encrypted_identity_id) { identity.encrypted_id }

      context 'with valid params' do
        let(:user_params) do
          {
            encrypted_identity_id: encrypted_identity_id,
            name: 'nickname', url: 'https://sample.com', location: 'Tokyo',
            email: 'new-user@example.com', email_confirmation: 'new-user@example.com',
            avatar: fixture_file_upload('images/image.jpg'),
          }
        end

        it do
          expect{ subject }.to change{ User.count }.by(1)
                          .and change{ identity.reload.user }.from(nil).to(be_kind_of(User))
          is_expected.to redirect_to root_path
        end
      end

      context 'with invalid params' do
        let(:user_params) do
          { encrypted_identity_id: encrypted_identity_id, name: '', email: '', email_confirmation: '' }
        end

        it do
          expect{ subject }.not_to change{ User.count }
          is_expected.to be_successful
        end
      end
    end


    context 'on password sign up' do
      context 'with valid params' do
        let(:user_params) do
          {
            password: 'password', password_confirmation: 'password',
            name: 'nickname', url: 'https://sample.com', location: 'Tokyo',
            email: 'new-user@example.com', email_confirmation: 'new-user@example.com',
            avatar: fixture_file_upload('images/image.jpg'), encrypted_identity_id: nil
          }
        end

        it do
          expect{ subject }.to change{ User.count }.by(1)
          is_expected.to redirect_to root_path
        end
      end

      context 'with invalid params' do
        let(:user_params) do
          {
            password: 'password', password_confirmation: 'wrong password',
            name: 'nickname', encrypted_identity_id: nil
          }
        end

        it do
          expect{ subject }.not_to change{ User.count }
          is_expected.to be_successful
        end
      end
    end
  end

  describe 'GET edit' do
    subject { get :edit }
    let(:user) { FactoryBot.create(:user) }
    before { sign_in(user) }
    it { is_expected.to be_successful }
  end

  describe 'PATCH update' do
    subject { patch :update, params: { user: user_params } }
    let(:user) { FactoryBot.create(:user, name: 'before') }
    before { sign_in(user) }

    context 'with valid params' do
      let(:user_params) { { name: 'after' } }
      it do
        expect{ subject }.to change{ user.reload.name }.from('before').to('after')
        is_expected.to redirect_to edit_user_path
      end
    end

    context 'with invalid params' do
      let(:user_params) { { name: '' } }
      it do
        expect{ subject }.not_to change{ user.reload.name }
        is_expected.to be_successful
      end
    end
  end

  describe 'DELETE destroy' do
    subject { delete :destroy, params: { id: user } }
    let!(:user) { FactoryBot.create(:user) }
    before { sign_in(user) }

    it do
      expect_any_instance_of(User).to receive(:resign!)
      subject
    end

    it { expect{ subject }.to change{ session[:su] }.from(user.id).to(nil) }
    it { is_expected.to redirect_to root_path }

    describe 'raise on User#resign!' do
      before { allow_any_instance_of(User).to receive(:resign!).and_raise(error) }

      context 'ActiveRecord::RecordNotSaved' do
        let(:error) { ActiveRecord::RecordNotSaved }
        it do
          is_expected.to redirect_to edit_user_path
          expect(flash[:alert]).to eq 'Something went wrong. Please try again later.'
        end
      end

      context 'ActiveRecord::RecordNotDestroyed' do
        let(:error) { ActiveRecord::RecordNotDestroyed }
        it do
          is_expected.to redirect_to edit_user_path
          expect(flash[:alert]).to eq 'Something went wrong. Please try again later.'
        end
      end
    end
  end

  describe 'PATCH #update_password' do
    subject { patch :update_password, params: params }

    context 'when password_digest does not exist' do # OAuth Sign up
      let(:user) { FactoryBot.create(:user, password_digest: nil) }
      let(:params) { { user_id: user.name, password: 'password', password_confirmation: 'password' } }

      it { is_expected.to redirect_to edit_user_path }
      it { expect{ subject }.to change{ user.reload.password_digest }.from(nil).to(String) }
    end

    context 'when password_digest exists' do # Password Sign up
      let(:user) do
        attrs = FactoryBot.attributes_for(:user).merge(password: current_password, password_confirmation: current_password)
        User::PasswordAuth.create(attrs)
      end
      let(:current_password) { 'current_password' }

      context 'with wrong current password' do
        let(:params) { { current_password: "wrong#{current_password}", user_id: user.name, password: 'password', password_confirmation: 'password' } }
        it do
          is_expected.to be_successful
          expect(flash.now[:danger]).to eq '現在のパスワードが間違っています'
        end
      end

      context 'with correct current password' do
        let(:params) { { current_password: current_password, user_id: user.name, password: password, password_confirmation: password_confirmation } }
        let(:password) { 'password' }

        context 'when password and password_confirmation are the same' do
          let(:password_confirmation) { password }
          it { is_expected.to redirect_to edit_user_path }
          it { expect{ subject }.to change{ user.reload.password_digest } }
        end

        context 'when password and password_confirmation are not the same' do
          let(:password_confirmation) { "wrong#{password}" }
          it { is_expected.to be_successful }
          it { expect{ subject }.not_to change{ user.reload.password_digest } }
        end
      end
    end
  end

  describe 'POST backup' do
    subject { post :backup, params: { user_id: user } }
    let(:user) { FactoryBot.create(:user) }

    context 'valid user' do
      before { sign_in user }
      it { is_expected.to redirect_to edit_user_path }
      it do
        expect(BackupJob).to receive(:perform_later).with(user)
        subject
      end
    end

    context 'invalid user' do
      before { sign_in FactoryBot.create(:user) }
      it { is_expected.to have_http_status :forbidden }
      it do
        expect(BackupJob).not_to receive(:perform_later).with(user)
        subject
      end
    end
  end

  describe 'GET download_backup' do
    subject { get :download_backup, params: { user_id: user } }
    let(:user) { FactoryBot.create(:user) }
    let(:backup) { Backup.new(user) }

    before do
      Rails.root.join('tmp', 'backup', 'zip').mkpath
      File.open(Rails.root.join('tmp', 'backup', 'zip', "#{user.name}_backup.zip"), 'w')
      sign_in user
    end

    it do
      expect(@controller).to receive(:send_file).with(backup.zip_path, filename: backup.zip_filename) { @controller.render nothing: true }
      subject
    end

    after do
      File.delete(backup.zip_path)
    end
  end
end
