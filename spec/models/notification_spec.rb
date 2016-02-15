require "spec_helper"

describe Notification do
  let(:notification){FactoryGirl.build :notification}
  describe "#was_read_before" do
    describe "was_read = true" do
      before do
        notification.was_read = true
        notification.updated_at = Time.zone.now - 2.hour
      end
      subject{notification.was_read_before(1.hour)}
      it{should be true}
    end
    describe "was_read = false" do
      before do
        notification.was_read = false
        notification.updated_at = Time.zone.now
      end
      subject{notification.was_read_before(1.hour)}
      it{should be false}
    end
  end
end
