# frozen_string_literal: true

shared_examples 'success' do
  subject { response.status }
  it { is_expected.to eq 200 }
end

shared_examples 'unauthorized' do
  subject { response.status }
  it { is_expected.to eq 401 }
end

shared_examples 'redirected' do
  subject { response.status }
  it { is_expected.to eq 302 }
end

shared_examples 'render template' do |name|
  subject { response }
  it { is_expected.to render_template name }
end

shared_examples 'operation without team privilege' do |klass|
  subject { response.status }
  it do
    if %w[status material way].include? klass
      is_expected.to eq 401
    else
      is_expected.to eq 200
    end
  end
end
