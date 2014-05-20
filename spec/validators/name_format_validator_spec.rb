require "spec_helper"

describe NameFormatValidator do
  class Validatable
    include ActiveModel::Validations
    attr_accessor :name
    validates :name, name_format: true
  end

  context "when the validatee value consists with alphanumerical (and '_') chars" do
    context "and starts with alphabet" do
      let(:model){Validatable.new.tap{|v| v.name = "valid_123"}}
      subject{model.valid?}
      it{should be_true}
    end
    context "and starts with numeric" do
      let(:model){Validatable.new.tap{|v| v.name = "123_valid"}}
      subject{model.valid?}
      it{should be_true}
    end
    context "and starts with underscore" do
      let(:model){Validatable.new.tap{|v| v.name = "_123valid"}}
      subject{model.valid?}
      it{should be_false}
    end
  end
  context "when the length of the validatee text is less than 3" do
    let(:model){Validatable.new.tap{|v| v.name = "ab"}}
    subject{model.valid?}
    it{should be_false}
  end
end
