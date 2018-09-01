# frozen_string_literal: true

describe Project do
  it_behaves_like 'Figurable', :user_project

  let(:project) { FactoryBot.create :user_project }
  let(:user1) { FactoryBot.create :user }
  let(:user2) { FactoryBot.create :user }

  it '.licenses' do
    expect(Project.licenses).to eq({ 'by' => 0, 'by-sa' => 1, 'by-nc' => 2, 'by-nc-sa' => 3 })
  end

  describe '.noted' do
    subject { Project.noted }

    let!(:project1) do
      FactoryBot.create(:project) do |project|
        FactoryBot.create(:note_card, project: project)
      end
    end
    let!(:project2) { FactoryBot.create(:project) }
    let!(:project3) do
      FactoryBot.create(:project) do |project|
        FactoryBot.create(:note_card, project: project)
      end
    end

    it { is_expected.to match_array([project1, project3]) }
  end

  describe '.search_draft' do
    let!(:project1) { FactoryBot.create(:project, title: '私はその人を常に先生と呼んでいた。') }
    let!(:project2) { FactoryBot.create(:project, description: 'だからここでもただ先生と書くだけで本名は打ち明けない。') }
    let!(:project3) do
      owner = FactoryBot.create(:user, fullname: '先生')
      FactoryBot.create(:project, owner: owner, description: 'その方が私にとって自然だからである。')
    end

    it { expect(Project.search_draft('先生')).to match_array [project1, project2, project3] }
    it { expect(Project.search_draft('先生 　その')).to match_array [project1, project3] }
  end

  describe '.find_with' do
    let!(:project) { FactoryBot.create(:project, name: 'my-project', owner: owner) }
    let!(:owner) { FactoryBot.create(:user, name: 'itkrt2y') }

    it { expect(Project.find_with(owner.slug, project.slug)).to eq project }
    it { expect{ Project.find_with('wrong', project.slug) }.to raise_error(ActiveRecord::RecordNotFound) }
    it { expect{ Project.find_with(owner.slug, 'wrong') }.to raise_error(ActiveRecord::RecordNotFound) }
  end

  describe '#collaborators' do
    subject { project.collaborators }
    let(:group) { FactoryBot.create(:group) }
    before do
      user1.collaborations.create(project: project)
      user2.collaborations.create(project: project)
      group.collaborations.create(project: project)
    end
    it { is_expected.to contain_exactly(user1, user2, group) }
  end

  describe '#fork_for!' do
    let(:forker) { FactoryBot.create :user }
    let(:derivative_project) { project.fork_for! forker }
    before do
      project.states.create!(type: Card::State.name, title: 'a state', description: 'desc a')
      project.states.create!(type: Card::State.name, title: 'b state', description: 'desc b')
      project.reload
    end
    it { expect(derivative_project.owner).to eq forker }
    it { expect(derivative_project.id).not_to eq project.id }

    it 'プロジェクトと複製先のstateの数が同じであること' do
      aggregate_failures do
        expect(project.states.count).to eq 2
        expect(derivative_project.states.count).to eq 2
      end
    end

    it 'プロジェクト名（slug）を維持すること' do
      expect(derivative_project.name).to eq(project.name)
      expect(derivative_project.slug).to eq(project.slug)
    end

    describe 'usagesを複製しない' do
      before { FactoryBot.create_list(:usage, usage_count, project: project) }
      let(:usage_count) { 3 }
      it '複製先では空であること' do
        expect(project.usages.count).to eq(usage_count)
        expect(derivative_project.usages.count).to eq(0)
      end
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

  describe '#root' do
    context '自身がルートのとき' do
      let(:project) { FactoryBot.create(:user_project, original: nil) }
      it '自身を返すこと' do
        expect(project.root).to eq(project)
      end
    end

    context '自身が別のrootプロジェクトをforkしているとき' do
      let(:root_project) { FactoryBot.create(:user_project, original: nil) }
      let(:project) { FactoryBot.create(:user_project, original: root_project) }
      it '親を返すこと' do
        expect(project.root).to eq(root_project)
      end
    end

    context '自身が別のrootプロジェクトのforkのforkのとき' do
      let(:root_project) { FactoryBot.create(:user_project, original: nil) }
      let(:parent_project) { FactoryBot.create(:user_project, original: root_project) }
      let(:project) { FactoryBot.create(:user_project, original: parent_project) }
      it 'ルートを返すこと' do
        expect(project.root).to eq(root_project)
      end
    end
  end

  describe '#is_fork?' do
    subject { project.is_fork? }
    let(:project) { Project.new(original_id: original_id) }

    context 'when original project' do
      let(:original_id) { nil }
      it { is_expected.to be false }
    end

    context 'when forked project' do
      let(:original_id) { 1 }
      it { is_expected.to be true }
    end
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
      expect(project.draft).to eq <<~EOS.chomp
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

  describe '#manageable_by?' do
    subject { project.manageable_by?(user) }

    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:user_project, owner: user, is_deleted: is_deleted) }
    let(:is_deleted) { false }

    context 'when the project is deleted' do
      let(:is_deleted) { true }
      it { is_expected.to be false }
    end

    context 'when user is a project manager' do
      before { allow(user).to receive(:is_project_manager?).and_return(true) }
      it { is_expected.to be true }
    end

    context 'when user is NOT a project manager' do
      before { allow(user).to receive(:is_project_manager?).and_return(false) }
      it { is_expected.to be false }
    end
  end
end
