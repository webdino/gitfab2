# frozen_string_literal: true

require 'spec_helper'

describe NotesController, type: :controller do
  render_views

  let(:project) { FactoryGirl.create :user_project }

  subject { response }

  describe 'GET show' do
    before do
      xhr :get, :show, owner_name: project.owner.name, project_id: project.name
    end
    it { is_expected.to render_template :show }
  end
end
