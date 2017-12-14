require "spec_helper"

describe GlobalProjectsController, type: :controller do
  # テスト用にdocker-composeで建てたSolrサーバを使うのでコメントアウト
  # disconnect_sunspot
  render_views

  describe 'GET index' do
    context 'without queries' do
      before{xhr :get, :index}
      it{expect(response).to render_template :index}
    end
    context 'with a querie' do
      before{xhr :get, :index, q: 'foo'}
      it{expect(response).to render_template :index}
    end

    context 'with multi queries' do
      before{xhr :get, :index, q: 'foo bar'}
      it{expect(response).to render_template :index}
    end

    context 'with empty queries' do
      before{xhr :get, :index, q: ''}
      it{expect(response).to render_template :index}
    end
  end

  shared_examples_for '検索結果' do |query, option|
    # TODO: Solrを止めたら部分一致のテストも追加すること
    it "完全一致(#{option})" do
      # 公開プロジェクト
      # デフォルトで公開になっているが明示的に
      public_user_project = FactoryGirl.create(:user_project, :public, option)
      public_group_prject = FactoryGirl.create(:group_project, :public, option)
      # 非公開プロジェクト
      private_user_project = FactoryGirl.create(:user_project, :private, option)
      # 削除済みプロジェクト
      deleted_user_project = FactoryGirl.create(:user_project, :soft_destroyed, option)
      # クエリと一致しないプロジェクト
      one_of_the_project = FactoryGirl.create(:user_project, :public)

      Project.reindex
      Sunspot.commit

      get :index, q: query

      aggregate_failures do
        expect(assigns(:projects)).to include(public_user_project, public_group_prject)
        expect(assigns(:projects)).not_to include(private_user_project)
        expect(assigns(:projects)).not_to include(deleted_user_project)
        expect(assigns(:projects)).not_to include(one_of_the_project)
      end
    end
  end

  describe '全文検索' do
    it_behaves_like '検索結果', 'sample', name: 'sample'
    it_behaves_like '検索結果', 'sample', title: 'sample'
    it_behaves_like '検索結果', 'sample', description: 'sample'
  end
end
