require 'spec_helper'

describe Api::V0::AnnotationsController, type: :request do
  disconnect_sunspot
  let(:auth_headers){{'HTTP_X_AUTH_KEY' => ENV['API_AUTH_KEY_0']}}
  subject{response}

  describe 'GET #index' do
    before do
      group = FactoryGirl.build :group, name: 'fabmodules'
      group.save
      @project = FactoryGirl.create(:group_project, owner: group)
      @state = @project.recipe.states.create(_type: Card::State.name, description: 'foo')
      @annotations = []
      @n = rand(10)
      @n.times do |i|
        @annotations.push @state.annotations.create(_type: Card::Annotation.name, description: 'foo')
      end
      @project.save
      get '/api/v0/groups/fabmodules/projects/' + @project.slug + '/recipe/states/' + @state.id.to_str + '/annotations/', {format: :json}, auth_headers
    end
    it 'response 200 & json data is same to state' do
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json.size).to eq @annotations.count
      annotations = @annotations.sort_by {|annotation| annotation.created_at}
      annotations.each_with_index do |annotation, i|
        expect(json[i]['id']).to eq annotation.id.to_str
      end
    end
  end

  describe 'GET #show' do
    before do
      group = FactoryGirl.build :group, name: 'fabmodules'
      group.save
      @project = FactoryGirl.create(:group_project, owner: group)
      @state = @project.recipe.states.create _type: Card::State.name, description: 'foo'
      @annotation = @state.annotations.create(_type: Card::Annotation.name, description: 'foo')
      @project.save
      get '/api/v0/groups/fabmodules/projects/' + @project.slug + '/recipe/states/' + @state.id.to_str + '/annotations/' + @annotation.id.to_str, {format: :json}, auth_headers
    end
    it 'response 200 & json data is same to state' do
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['id']).to eq @annotation.id.to_str
    end
  end

end
