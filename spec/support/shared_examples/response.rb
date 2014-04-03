require "spec_helper"

shared_examples "success" do
  subject{response.status}
  it{should be 200}
end

shared_examples "unauthorized" do
  subject{response.status}
  it{should be 401}
end

shared_examples "redirected" do
  subject{response.status}
  it{should be 302}
end

shared_examples "render template" do |name|
  subject{response}
  it{should render_template name}
end

shared_examples "operation without team privilege" do |klass|
  subject{response.status}
  it do
    if ["status", "material"].include? klass
      should be 401
    else
      should be 200
    end
  end
end
