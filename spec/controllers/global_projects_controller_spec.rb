require "spec_helper"

describe GlobalProjectsController, type: :controller do
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

  shared_examples_for '完全一致' do |query, option|
    it "検索結果(#{option})" do
      # 公開プロジェクト
      # デフォルトで公開になっているが明示的に
      public_user_project = FactoryGirl.create(:user_project, :public, option)
      public_group_prject = FactoryGirl.create(:group_project, :public, option)
      # 非公開プロジェクト
      private_user_project = FactoryGirl.create(:user_project, :private, option)
      # 削除済みプロジェクト
      deleted_user_project = FactoryGirl.create(:user_project, :soft_destroyed, option)
      # クエリと完全一致しないプロジェクト
      one_of_the_project = FactoryGirl.create(:user_project, :public, title: 'samplesample')

      Project.reindex
      Sunspot.commit

      get :index, q: query

      expect(assigns(:projects)).to include(public_user_project, public_group_prject)

      aggregate_failures do
        expect(assigns(:projects)).not_to include(private_user_project)
        expect(assigns(:projects)).not_to include(deleted_user_project)
        expect(assigns(:projects)).not_to include(one_of_the_project)
      end
    end
  end

  shared_examples_for '部分一致' do |query, option|
    # TODO: Solrを止めたらpendingも止めること
    xit "検索結果(#{option})" do
      public_user_project = FactoryGirl.create(:user_project, :public, option)
      public_group_prject = FactoryGirl.create(:group_project, :public, option)
      private_user_project = FactoryGirl.create(:user_project, :private, option)
      deleted_user_project = FactoryGirl.create(:user_project, :soft_destroyed, option)
      # クエリと部分一致しないプロジェクト
      # TODO: もう少しパターンを増やす必要あり？
      one_of_the_project = FactoryGirl.create(:user_project, :public, title: 'foo')

      Project.reindex
      Sunspot.commit

      get :index, q: query

      expect(assigns(:projects)).to include(public_user_project, public_group_prject)

      aggregate_failures do
        expect(assigns(:projects)).not_to include(private_user_project)
        expect(assigns(:projects)).not_to include(deleted_user_project)
        expect(assigns(:projects)).not_to include(one_of_the_project)
      end
    end
  end

  describe '全文検索' do
    it_behaves_like '完全一致', 'sample', name: 'sample'
    it_behaves_like '完全一致', 'sample', title: 'sample'
    it_behaves_like '完全一致', 'sample', description: 'sample'

    # クエリは空白文字区切りで単語に分ける
    it_behaves_like '部分一致', 'foo bar', name: 'foobar'
    it_behaves_like '部分一致', 'foo bar', title: 'foobar'
    it_behaves_like '部分一致', 'foo bar', description: 'foobar'
  end
end
