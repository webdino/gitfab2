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
