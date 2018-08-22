# frozen_string_literal: true

describe GlobalProjectsController, type: :controller do
  render_views

  describe 'GET index' do
    context 'without queries' do
      before { get :index, xhr: true }
      it { expect(response).to render_template :index }
    end
    context 'with a querie' do
      before { get :index, params: { q: 'foo' }, xhr: true }
      it { expect(response).to render_template :index }
    end

    context 'with multi queries' do
      before { get :index, params: { q: 'foo bar' }, xhr: true }
      it { expect(response).to render_template :index }
    end

    context 'with empty queries' do
      before { get :index, params: { q: '' }, xhr: true }
      it { expect(response).to render_template :index }
    end
  end

  shared_examples_for '検索結果' do |query|
    it do
      get :index, params: { q: query }
      expect(assigns(:projects)).to include(public_user_project, public_group_project)

      aggregate_failures do
        expect(assigns(:projects)).not_to include(private_user_project)
        expect(assigns(:projects)).not_to include(deleted_user_project)
        expect(assigns(:projects)).not_to include(one_of_the_project)
      end
    end
  end

  shared_examples_for '検索結果(public user project only)' do |query|
    it do
      get :index, params: { q: query }
      expect(assigns(:projects)).to include(public_user_project)

      aggregate_failures do
        expect(assigns(:projects)).not_to include(public_group_project)
        expect(assigns(:projects)).not_to include(private_user_project)
        expect(assigns(:projects)).not_to include(deleted_user_project)
        expect(assigns(:projects)).not_to include(one_of_the_project)
      end
    end
  end

  shared_examples_for '検索結果(public group project only)' do |query|
    it do
      get :index, params: { q: query }
      expect(assigns(:projects)).to include(public_group_project)

      aggregate_failures do
        expect(assigns(:projects)).not_to include(public_user_project)
        expect(assigns(:projects)).not_to include(private_user_project)
        expect(assigns(:projects)).not_to include(deleted_user_project)
        expect(assigns(:projects)).not_to include(one_of_the_project)
      end
    end
  end

  describe 'Search projects by name' do
    shared_context 'projects with name' do |matched, unmatched|
      # 公開プロジェクト
      # デフォルトで公開になっているが明示的に
      let!(:public_user_project) { FactoryBot.create(:user_project, :public, name: matched) }
      let!(:public_group_project) { FactoryBot.create(:group_project, :public, name: matched) }
      # 非公開プロジェクト
      let!(:private_user_project) { FactoryBot.create(:user_project, :private, name: matched) }
      # 削除済みプロジェクト
      let!(:deleted_user_project) { FactoryBot.create(:user_project, :soft_destroyed, name: matched) }
      # クエリと一致しないプロジェクト
      let!(:one_of_the_project) { FactoryBot.create(:user_project, :public, name: unmatched) }
    end

    context '完全一致' do
      include_context 'projects with name', 'sample', 'zample'
      include_examples '検索結果', 'sample'
    end

    context '部分一致' do
      include_context 'projects with name', 'foobar', 'foo'
      include_examples '検索結果', 'foo bar'
    end
  end

  describe 'Search projects by title' do
    shared_context 'projects with title' do |matched, unmatched|
      let!(:public_user_project) { FactoryBot.create(:user_project, :public, title: matched) }
      let!(:public_group_project) { FactoryBot.create(:group_project, :public, title: matched) }
      let!(:private_user_project) { FactoryBot.create(:user_project, :private, title: matched) }
      let!(:deleted_user_project) { FactoryBot.create(:user_project, :soft_destroyed, title: matched) }
      let!(:one_of_the_project) { FactoryBot.create(:user_project, :public, title: unmatched) }
    end

    context '完全一致' do
      include_context 'projects with title', 'sample', 'zample'
      include_examples '検索結果', 'sample'
    end

    context '部分一致' do
      include_context 'projects with title', 'foobar', 'foo'
      include_examples '検索結果', 'foo bar'
    end
  end

  describe 'Search projects by description' do
    shared_context 'projects with description' do |matched, unmatched|
      let!(:public_user_project) { FactoryBot.create(:user_project, :public, description: matched) }
      let!(:public_group_project) { FactoryBot.create(:group_project, :public, description: matched) }
      let!(:private_user_project) { FactoryBot.create(:user_project, :private, description: matched) }
      let!(:deleted_user_project) { FactoryBot.create(:user_project, :soft_destroyed, description: matched) }
      let!(:one_of_the_project) { FactoryBot.create(:user_project, :public, description: unmatched) }
    end

    context '完全一致' do
      include_context 'projects with description', 'sample', 'zample'
      include_examples '検索結果', 'sample'
    end

    context '部分一致' do
      include_context 'projects with description', 'foobar', 'foo'
      include_examples '検索結果', 'foo bar'
    end
  end

  describe 'Search projects by tag' do
    shared_context 'projects' do
      let!(:public_user_project) { FactoryBot.create(:user_project, :public) }
      let!(:public_group_project) { FactoryBot.create(:group_project, :public) }
      let!(:private_user_project) { FactoryBot.create(:user_project, :private) }
      let!(:deleted_user_project) { FactoryBot.create(:user_project, :soft_destroyed) }
      let!(:one_of_the_project) { FactoryBot.create(:user_project, :public) }
    end

    context '完全一致' do
      let!(:tag_hash) { FactoryBot.build(:tag, name: 'sample').attributes }
      include_context 'projects'

      before do
        [public_user_project, public_group_project,
         private_user_project, deleted_user_project].each do |project|
          project.tags.create(tag_hash)
        end

        tag_hash['name'] = 'zample'
        one_of_the_project.tags.create(tag_hash)

        [public_user_project, public_group_project,
         private_user_project, deleted_user_project, one_of_the_project].each(&:update_draft!)
      end

      include_examples '検索結果', 'sample'
    end

    context '部分一致' do
      let!(:tag_hash) { FactoryBot.build(:tag, name: 'foobar').attributes }
      include_context 'projects'

      before do
        [public_user_project, public_group_project,
         private_user_project, deleted_user_project].each do |project|
          project.tags.create(tag_hash)
        end

        tag_hash['name'] = 'foo'
        one_of_the_project.tags.create(tag_hash)

        [public_user_project, public_group_project,
         private_user_project, deleted_user_project, one_of_the_project].each(&:update_draft!)
      end

      include_examples '検索結果', 'foo bar'
    end
  end

  describe 'Search projects by project' do
    shared_context 'projects' do
      let!(:public_user_project) { FactoryBot.create(:user_project, :public) }
      let!(:public_group_project) { FactoryBot.create(:group_project, :public) }
      let!(:private_user_project) { FactoryBot.create(:user_project, :private) }
      let!(:deleted_user_project) { FactoryBot.create(:user_project, :soft_destroyed) }
      let!(:one_of_the_project) { FactoryBot.create(:user_project, :public) }
    end

    context '完全一致' do
      include_context 'projects'

      before do
        state_attributes = FactoryBot.attributes_for(:state, description: 'sample')
        [public_user_project, public_group_project,
         private_user_project, deleted_user_project].each do |project|
          project.states.create!(state_attributes)
        end

        state_attributes[:description] = 'zample'
        one_of_the_project.states.create!(state_attributes)

        [public_user_project, public_group_project,
         private_user_project, deleted_user_project, one_of_the_project].each do |project|
          project.update_draft!
        end
      end

      include_examples '検索結果', 'sample'
    end

    context '部分一致' do
      include_context 'projects'

      before do
        state_attributes = FactoryBot.attributes_for(:state, description: 'foobar')
        [public_user_project, public_group_project, private_user_project, deleted_user_project].each do |project|
          project.states.create!(state_attributes)
        end

        state_attributes[:description] = 'foo'
        one_of_the_project.states.create!(state_attributes)

        [public_user_project, public_group_project,
         private_user_project, deleted_user_project, one_of_the_project].each(&:update_draft!)
      end

      include_examples '検索結果', 'foo bar'
    end
  end

  shared_context 'projects with owner' do
    let!(:public_user_project) { FactoryBot.create(:user_project, :public, owner: user) }
    let!(:public_group_project) { FactoryBot.create(:group_project, :public, owner: group) }
    let!(:private_user_project) { FactoryBot.create(:user_project, :private, owner: user) }
    let!(:deleted_user_project) { FactoryBot.create(:user_project, :soft_destroyed, owner: user) }
    let!(:one_of_the_project) { FactoryBot.create(:user_project, :public, owner: one_of_the_users) }
  end

  describe 'Search projects by owner name' do
    let!(:user) { FactoryBot.create(:user, name: 'sample-user') }
    let!(:one_of_the_users) { FactoryBot.create(:user, name: 'one-of-the-users') }
    let!(:group) { FactoryBot.create(:group, name: 'sample-group') }

    include_context 'projects with owner'

    context '完全一致' do
      # userとgroupで名前が重複できないのでどちらか一方だけが返ってくる結果を期待する
      include_examples '検索結果(public user project only)', 'sample-user'
      include_examples '検索結果(public group project only)', 'sample-group'
    end

    context '部分一致' do
      include_examples '検索結果', 'sample'
    end
  end

  describe 'Search projects by user fullname' do
    let!(:user) { FactoryBot.create(:user, fullname: 'sample-user') }
    let!(:one_of_the_users) { FactoryBot.create(:user, fullname: 'one-of-the-users') }
    # group has no fullnameなので今回のテスト対象ではないが
    # shared_context内で必要なので用意する
    let!(:group) { FactoryBot.create(:group, name: 'sample-group') }

    include_context 'projects with owner'

    # groupはfullnameを持っていないので、userだけが返ってくる結果を期待する
    context '完全一致' do
      include_examples '検索結果(public user project only)', 'sample-user'
    end

    context '部分一致' do
      include_examples '検索結果(public user project only)', 'sample user'
    end
  end

  describe 'Search projects by url' do
    let!(:user) { FactoryBot.create(:user, url: 'https://sample.com') }
    let!(:one_of_the_users) { FactoryBot.create(:user, url: 'https://oneoftheusers.com') }
    let!(:group) { FactoryBot.create(:group, url: 'https://sample.com') }

    include_context 'projects with owner'

    context '完全一致' do
      include_examples '検索結果', 'https://sample.com'
    end

    context '部分一致' do
      include_examples '検索結果', 'sample'
    end
  end

  describe 'Search projects by location' do
    let!(:user) { FactoryBot.create(:user, location: 'Tokyo,Japan') }
    let!(:one_of_the_users) { FactoryBot.create(:user, location: 'Hachinohe,Japan') }
    let!(:group) { FactoryBot.create(:group, location: 'Tokyo,Japan') }

    include_context 'projects with owner'

    context '完全一致' do
      include_examples '検索結果', 'Tokyo,Japan'
    end

    context '部分一致' do
      include_examples '検索結果', 'Tokyo Japan'
    end
  end

  describe 'Search project by zenkaku-space or tab separated query' do
    shared_context 'projects with name' do |matched, unmatched|
      let!(:public_user_project) { FactoryBot.create(:user_project, :public, name: matched) }
      let!(:public_group_project) { FactoryBot.create(:group_project, :public, name: matched) }
      let!(:private_user_project) { FactoryBot.create(:user_project, :private, name: matched) }
      let!(:deleted_user_project) { FactoryBot.create(:user_project, :soft_destroyed, name: matched) }
      let!(:one_of_the_project) { FactoryBot.create(:user_project, :public, name: unmatched) }
    end

    context '部分一致' do
      include_context 'projects with name', 'foobar', 'foo'
      include_examples '検索結果', "foo　\tbar"
    end
  end
end
