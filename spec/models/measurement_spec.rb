# == Schema Information
#
# Table name: measurements
#
#  id         :integer          not null, primary key
#  sensor_id  :integer
#  value      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

include Utilities

describe Measurement do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
    @user.save!
    @sensor = Sensor.new(name: "Example Sensor", sensor_type_id: SensorType.find_by_name("generic").id,
                         user_id: @user.id, controller: "House", addressH: 1, addressL: 2)
    @sensor.save!

    @measurement = Measurement.new(sensor_id: @sensor.id, value: 60.5, check_value: "60.5", check_hash: request_key("60.5"))

  end

  subject { @measurement }

  it { should respond_to(:sensor_id) }
  it { should respond_to(:value) }

  it { should be_valid }

  describe "print validation errors" do
    it "should have no errors" do
      pp @measurement.valid?
      @measurement.errors.full_messages.should == []
    end
  end

  describe "when sensor is not filled in" do
    before { @measurement.sensor_id = nil }
    it { should_not be_valid }
  end

  describe "when sensor is not present" do
    before { @measurement.sensor_id = -1 }
    it { should_not be_valid }
  end

  describe "when value is not filled in" do
    before { @measurement.value = nil }
    it { should_not be_valid }
  end

  describe "when hash is invalid" do
    before { @measurement.check_hash = "xxx" }
    it { should_not be_valid }
  end

  describe "Saved value should take into account offset and scale" do
    before do
      @sensor.offset = 15
      @sensor.scale = 2
      @sensor.save!
      pp request_key("60.5")
      pp request_key("Office")
      @measurement = Measurement.new(sensor_id: @sensor.id, value: 60.5, check_value: "60.5", check_hash: request_key("60.5"))
      @measurement.save!
    end
    it {@measurement.reload.value.should eql(60.5*2 + 15)}
  end
end
