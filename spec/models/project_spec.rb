# frozen_string_literal: true

describe Project do
  it_behaves_like 'Likable', :user_project
  it_behaves_like 'Figurable', :user_project
  it_behaves_like 'Contributable', :user_project
  it_behaves_like 'Commentable', :user_project
  it_behaves_like 'Taggable', :user_project

  let(:project) { FactoryBot.create :user_project }
  let(:user1) { FactoryBot.create :user }
  let(:user2) { FactoryBot.create :user }

  describe '#collaborators' do
    before do
      user1.collaborations.create project: project
      user2.collaborations.create project: project
    end
    subject { project.collaborators }
    it { is_expected.to eq [user1, user2] }
  end

  describe '#fork_for!' do
    let(:forker) { FactoryBot.create :user }
    let(:derivative_project) { project.fork_for! forker }
    before do
      project.recipe.states.create type: Card::State.name,
                                   title: 'a state', description: 'desc a'
      project.recipe.states.create type: Card::State.name,
                                   title: 'b state', description: 'desc b'
      project.reload
    end
    it { expect(derivative_project.owner).to eq forker }
    it { expect(derivative_project.id).not_to eq project.id }

    it 'プロジェクトと複製先のstateの数が同じであること' do
      aggregate_failures do
        expect(project.recipe.states.size).to eq 2
        expect(derivative_project.recipe.states.size).to eq 2
      end
    end

    it 'プロジェクト名（slug）を維持すること' do
      expect(derivative_project.name).to eq(project.name)
      expect(derivative_project.slug).to eq(project.slug)
    end

    describe 'usagesを複製しない' do
      let(:recipe) { FactoryBot.create(:recipe) }
      it '複製先では空であること' do
        expect(project.usages.size).to_not eq(0)
        expect(derivative_project.usages.size).to eq(0)
      end
    end
  end

  describe '#change_owner!(owner)' do
    it 'returns true' do
      expect(project.change_owner!(user1)).to be_truthy
    end

    it 'changes to other user.' do
      expect { project.change_owner!(user1) }.to change { project.owner }.to(user1)
    end

    it 'changes to other group.' do
      group = FactoryBot.create(:group)
      expect { project.change_owner!(group) }.to change { project.owner }.to(group)
    end
  end

  describe '#managers' do
    context 'ownerがUserのとき' do
      let(:project) { FactoryBot.create(:user_project) }
      it 'ownerのみであること' do
        expect(project.managers).to contain_exactly(project.owner)
      end
    end
    context 'ownerがGroupのとき' do
      let(:project) { FactoryBot.create(:group_project) }
      before do
        user1.memberships.create(group_id: project.owner.id, role: 'admin')
        user2.memberships.create(group_id: project.owner.id, role: 'editor')
      end
      it 'Groupのメンバーであること' do
        expect(project.managers).to contain_exactly(user1, user2)
      end
    end
  end

  describe '#potential_owners' do
    context 'ownerがUserのとき' do
      let(:project) { FactoryBot.create(:user_project) }
      let(:owner) { project.owner }
      let(:group_a) { FactoryBot.create(:group) }
      let(:group_b) { FactoryBot.create(:group) }
      let(:collaborate_user) { FactoryBot.create(:user) }
      before do
        owner.memberships.create(group_id: group_a.id, role: 'admin')
        owner.memberships.create(group_id: group_b.id, role: 'editor')
        collaborate_user.collaborate!(project)
      end
      it '所属グループ + collaborators' do
        expect(project.potential_owners).to contain_exactly(group_a, group_b, collaborate_user)
      end
    end
    context 'ownerがGroupのとき' do
      let(:project) { FactoryBot.create(:group_project) }
      let(:owner) { project.owner }
      let(:group_user_a) { FactoryBot.create(:user) }
      let(:group_user_b) { FactoryBot.create(:user) }
      let(:collaborate_user) { FactoryBot.create(:user) }
      before do
        group_user_a.memberships.create(group_id: owner.id, role: 'admin')
        group_user_b.memberships.create(group_id: owner.id, role: 'editor')
        collaborate_user.collaborate!(project)
      end
      it 'グループのメンバー + collaborators' do
        expect(project.potential_owners).to contain_exactly(group_user_a, group_user_b, collaborate_user)
      end
    end
  end

  describe '#root(project)' do
    context '自身がルートのとき' do
      let(:project) { FactoryBot.create(:user_project, original: nil) }
      it '自身を返すこと' do
        expect(project.root(project)).to eq(project)
      end
    end

    context '自身が別のrootプロジェクトをforkしているとき' do
      let(:root_project) { FactoryBot.create(:user_project, original: nil) }
      let(:project) { FactoryBot.create(:user_project, original: root_project) }
      it '親を返すこと' do
        expect(project.root(project)).to eq(root_project)
      end
    end

    context '自身が別のrootプロジェクトのforkのforkのとき' do
      let(:root_project) { FactoryBot.create(:user_project, original: nil) }
      let(:parent_project) { FactoryBot.create(:user_project, original: root_project) }
      let(:project) { FactoryBot.create(:user_project, original: parent_project) }
      it 'ルートを返すこと' do
        expect(project.root(project)).to eq(root_project)
      end
    end
  end

  describe '#thumbnail' do
    context 'YouTube動画が設定されている時' do
      before do
        allow(project.figures.first).to receive_messages(link: 'hogehoge')
      end
      it '動画サムネイルURLを返すこと' do
        expect(project.thumbnail).to eq('https://img.youtube.com/vi/hogehoge/mqdefault.jpg')
      end
    end
    context '画像が設定されている時' do
      let(:figure_content_small_url) { 'http://test.host/small.jpg' }
      before do
        uploader_content = double('content', small: figure_content_small_url)
        allow(project.figures.first).to receive_messages(
          link: nil,
          content: uploader_content
        )
      end
      it '画像サムネイルURLを返すこと' do
        expect(project.thumbnail).to eq(figure_content_small_url)
      end
    end
    context '画像・動画が設定されていない時' do
      it '規定のURLを返すこと' do
        expect(project.thumbnail).to eq('fallback/blank.png')
      end
    end
  end

  it '#licenses' do
    expect(project.licenses).to contain_exactly('by', 'by-sa', 'by-nc', 'by-nc-sa')
  end

  describe '#update_draft!' do
    let!(:owner) { FactoryBot.create(:user, name: 'user1', fullname: 'User One', url: 'http://example.com', location: 'Tokyo') }
    let!(:project) { FactoryBot.create(:user_project, name: 'name', title: 'title', description: 'description', owner: owner) }

    it "generates a draft which contains project and owner's draft" do
      expect(project.draft).to eq <<~EOS.chomp
        name
        title
        description
        user1
        User One
        http://example.com
        Tokyo
      EOS
    end

    it "generates a draft which contains tag's draft" do
      tag1 = project.tags.build(name: 'tag1', user_id: owner.id)
      tag1.save!
      tag2 = project.tags.build(name: 'tag2', user_id: owner.id)
      tag2.save!
      project.update_draft!
      expect(project.draft).to eq <<~EOS
        name
        title
        description
        user1
        User One
        http://example.com
        Tokyo
        tag1
        tag2
      EOS
    end
  end
end
