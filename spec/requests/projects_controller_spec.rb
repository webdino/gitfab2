require 'spec_helper'

describe Api::V0::ProjectsController, type: :request do
  disconnect_sunspot
  subject{response}

  let(:auth_headers){{'HTTP_X_AUTH_KEY' => ENV['API_AUTH_KEY_0']}}

  describe '#index' do
    before do
      group = FactoryGirl.build :group, name: 'fabmodules'
      group.save
      @projects = []
      @n = rand(10)
      @n.times do |i|
        @projects.push FactoryGirl.build(:group_project, owner: group)
      end
      @projects.map{|project| project.save}
      get '/api/v0/groups/fabmodules/projects', {format: :json}, auth_headers
    end
    it 'GET fabmodules projects' do
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json.size).to eq @projects.count
      projects = @projects.sort_by {|project| project.created_at}
      projects.each_with_index do |project, i|
        expect(json[i]['id']).to eq project.id.to_str
      end
    end
  end

  describe '#show' do
    before do
      group = FactoryGirl.build :group, name: 'fabmodules'
      group.save
      @project = FactoryGirl.build(:group_project, owner: group)
      @project.save
      get '/api/v0/groups/fabmodules/projects/' + @project.slug, {format: :json}, auth_headers
    end
    it 'GET project' do
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['id']).to eq @project.id.to_str
    end
  end

end
