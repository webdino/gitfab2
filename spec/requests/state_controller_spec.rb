require 'spec_helper'

describe Api::V0::StatesController, type: :request do
  disconnect_sunspot

  # let(:project){FactoryGirl.create :user_project}
  # let(:state){project.recipe.states.create _type: Card::State.name, description: 'foo'}
  # let(:new_state){FactoryGirl.build :state}

  let(:auth_headers){{'HTTP_X_AUTH_KEY' => ENV['API_AUTH_KEY_0']}}

  subject{response}

  describe 'GET #index' do
    before do
      group = FactoryGirl.build :group, name: 'fabmodules'
      group.save
      @project = FactoryGirl.create(:group_project, owner: group)
      @states = []
      @n = rand(10)
      @n.times do |i|
        @states.push @project.recipe.states.create(_type: Card::State.name, description: 'foo')
      end
      @project.save
      get '/api/v0/groups/fabmodules/projects/' + @project.slug + '/recipe/states/', {format: :json}, auth_headers
    end
    it 'response 200 & json data is same to state' do
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json.size).to eq @states.count
      states = @states.sort_by {|state| state.created_at}
      states.each_with_index do |state, i|
        expect(json[i]['id']).to eq state.id.to_str
      end
    end
  end

  describe 'GET #show' do
    before do
      group = FactoryGirl.build :group, name: 'fabmodules'
      group.save
      @project = FactoryGirl.create(:group_project, owner: group)
      @state = @project.recipe.states.create _type: Card::State.name, description: 'foo'
      @project.save
      get '/api/v0/groups/fabmodules/projects/' + @project.slug + '/recipe/states/' + @state.id.to_str, {format: :json}, auth_headers
    end
    it 'response 200 & json data is same to state' do
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['id']).to eq @state.id.to_str
    end
  end

end
