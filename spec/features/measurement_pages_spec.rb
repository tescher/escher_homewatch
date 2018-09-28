require 'rails_helper'
include Utilities

describe "MeasurementPages" do

  before(:each) do
    3.times { FactoryBot.create(:user) }
    User.all.each do |user|
      2.times { FactoryBot.create(:sensor, user_id: user.id, controller: user.name, offset: 15, scale: 2) }
    end
  end
  after(:each) do
    User.delete_all
    Sensor.delete_all
  end

  subject { page }


  describe "put data" do
    before { @sensor = Sensor.first }

    it "Should add a value to the database" do
      expect do
        post measurements_path, sensor_id: @sensor.id, value: 60.5, key: request_key("60.5")
        pp response.body
      end.to change(Measurement, :count).by(1)
    end

    #it "Should not add an invalid value to the database" do
    #  expect do
    #    post measurements_path, sensor_id: @sensor.id, value: "Hello"
    #    pp response.body
    #  end.to change(Measurement, :count).by(0)
    #end
    it "Should not add a value to an invalid sensor" do
      expect do
        post measurements_path, sensor_id: "Hello", value: "60.5", key: request_key("60.5")
        pp response.body
      end.to change(Measurement, :count).by(0)
    end
  end

  describe "get data" do

    before do
      @sensor = Sensor.first
    end

    it "should retrieve the value just entered" do
      post measurements_path, sensor_id: @sensor.id, monitor_sensor_id: 1, value: 60.5, key: request_key("60.5")
      pp response.body
      get measurements_path, sensor_id: @sensor.id
      parsed_body = JSON.parse(response.body)
      pp parsed_body
      parsed_body["label"].should  == @sensor.name
      parsed_body["id"].should == @sensor.id.to_s
      parsed_body["data"].count.should == 1
      parsed_body["data"][0][1].should == (60.5*2+15)
    end

  end

end