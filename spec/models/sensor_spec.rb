# == Schema Information
#
# Table name: sensors
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  sensor_type_id      :integer
#  user_id             :integer
#  group               :string(255)
#  controller          :string(255)
#  addressH            :integer
#  addressL            :integer
#  offset              :float
#  scale               :float
#  interval            :integer
#  trigger_upper_limit :float
#  trigger_lower_limit :float
#  trigger_delay       :integer
#  trigger_email       :string(255)
#  trigger_enabled     :boolean
#  absence_alert       :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  trigger_lower_name  :string(255)
#  trigger_upper_name  :string(255)
#

require 'spec_helper'

describe Sensor do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
    @user.save!
    @sensor = Sensor.new(name: "Example Sensor", sensor_type_id: SensorType.find_by_name("generic").id,
                         user_id: @user.id, controller: "House", addressH: 1, addressL: 2)

  end

  subject { @sensor }

  it { should respond_to(:name) }
  it { should respond_to(:sensor_type_id) }
  it { should respond_to(:user_id) }
  it { should respond_to(:group) }
  it { should respond_to(:controller) }
  it { should respond_to(:addressH) }
  it { should respond_to(:addressL) }
  it { should respond_to(:offset) }
  it { should respond_to(:scale) }
  it { should respond_to(:interval) }
  it { should respond_to(:trigger_upper_limit) }
  it { should respond_to(:trigger_lower_limit) }
  it { should respond_to(:trigger_delay) }
  it { should respond_to(:trigger_email) }
  it { should respond_to(:trigger_enabled) }
  it { should respond_to(:absence_alert) }

  it { should be_valid }

  describe "print validation errors" do
    it "should have no errors" do
      pp @sensor.valid?
      pp @user
      @sensor.errors.full_messages.should == []
    end
  end

  describe "when name is not present" do
    before { @sensor.name = " " }
    it { should_not be_valid }
  end

  describe "when type is not present" do
    before { @sensor.sensor_type_id = nil }
    it { should_not be_valid }
  end

  describe "when type does not exist" do
    before { @sensor.sensor_type_id = -1 }
    it { should_not be_valid }
  end

  describe "when user account is not present" do
    before { @sensor.user_id = nil }
    it { should_not be_valid }
  end

  describe "when user account does not exist" do
    before { @sensor.user_id = -1 }
    it { should_not be_valid }
  end

  describe "when controller is not present" do
    before { @sensor.controller = " " }
    it { should_not be_valid }
  end

  describe "when addressH is not present" do
    before { @sensor.addressL = " " }
    it { should_not be_valid }
  end

  describe "when addressL is not present" do
    before { @sensor.addressH = " " }
    it { should_not be_valid }
  end

  describe "when another device already has that address" do
    before do
      sensor_with_same_address = @sensor.dup
      sensor_with_same_address.save
    end

    it { should_not be_valid }
  end


  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @sensor.trigger_email = invalid_address
        @sensor.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @sensor.trigger_email = valid_address
        @sensor.should be_valid
      end
    end
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @sensor.trigger_email = mixed_case_email
      @sensor.save
      @sensor.reload.trigger_email.should == mixed_case_email.downcase
    end
  end
end
