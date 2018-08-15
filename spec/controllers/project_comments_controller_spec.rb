describe ProjectCommentsController, type: :controller do
  describe 'POST #create' do
    subject { post :create, params: params }

    let(:project) { FactoryBot.create(:project) }
    let(:user) { FactoryBot.create(:user) }

    before { sign_in user }

    context 'with valid parameters' do
      let(:params) do
        {
          owner_name: project.owner.slug,
          project_id: project.id,
          project_comment: { body: 'valid' }
        }
      end

      it { is_expected.to redirect_to project_path(project.owner.slug, project, anchor: "project-comment-#{ProjectComment.last.id}") }

      it { expect{ subject }.to change(ProjectComment, :count).by(1) }

      specify 'commented by a signed in user' do
        subject
        expect(ProjectComment.last.user).to eq user
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          owner_name: project.owner.slug,
          project_id: project.id,
          project_comment: { body: nil }
        }
      end

      it { is_expected.to redirect_to project_path(project.owner.slug, project, anchor: "project-comment-form") }

      it { expect{ subject }.to change(ProjectComment, :count).by(0) }

      it do
        subject
        expect(flash[:alert]).to include "Body can't be blank"
      end
    end

    context 'When body length is over than 300 chars' do
      let(:params) do
        {
          owner_name: project.owner.slug,
          project_id: project.id,
          project_comment: { body: 'a'*301 }
        }
      end

      it { is_expected.to redirect_to project_path(project.owner.slug, project, anchor: "project-comment-form") }

      it { expect{ subject }.to change(ProjectComment, :count).by(0) }

      it do
        subject
        expect(flash[:alert]).to include 'Body is too long (maximum is 300 characters)'
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: params }

    let(:params) do
      {
        owner_name: project.owner.slug,
        project_id: project.id,
        id: project_comment.id
      }
    end

    let!(:project) { FactoryBot.create(:project) }
    let(:project_comment) { FactoryBot.create(:project_comment, user: FactoryBot.create(:user), project: project, body: 'valid') }

    before do
      sign_in project.owner
      project_comment
    end

    it { is_expected.to redirect_to project_path(project.owner.slug, project, anchor: "project-comments") }

    it { expect{ subject }.to change(ProjectComment, :count).by(-1) }

    context 'when user could not delete a comment' do
      before { allow_any_instance_of(ProjectComment).to receive(:destroy).and_return(false) }

      it { is_expected.to redirect_to project_path(project.owner.slug, project, anchor: "project-comments") }

      it { expect{ subject }.to change(ProjectComment, :count).by(0) }

      it do
        subject
        expect(flash[:alert]).to eq 'Comment could not be deleted'
      end
    end

    context 'when current user can not manage the project' do
      let(:not_manager) { FactoryBot.create(:user) }

      before do
        sign_in not_manager
        project_comment
      end

      it { is_expected.to redirect_to project_path(project.owner.slug, project, anchor: "project-comments") }

      it { expect{ subject }.to change(ProjectComment, :count).by(0) }

      it do
        subject
        expect(flash[:alert]).to eq 'You can not delete a comment'
      end
    end
  end

  describe 'Notification' do
    subject { Notification.last }

    let(:project) { FactoryBot.create(:project) }
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in user
      post :create, params: { owner_name: project.owner.slug,
                              project_id: project.id,
                              project_comment: { body: 'valid' } }
    end

    it do
      is_expected.to have_attributes(
        notifier_id: user.id,
        notified_id: project.owner.id,
        notificatable_url: project_path(project, owner_name: project.owner.slug),
        notificatable_type: 'Project',
        body: "#{user.name} commented on #{project.title}."
      )
    end
  end
end
