require 'rails_helper'

describe "SensorPages" do
  include SessionsHelper

  before(:each) do
    3.times { FactoryBot.create(:user) }
    User.all.each do |user|
      2.times { FactoryBot.create(:sensor, user_id: user.id, controller: "BasementArduino") }
    end
  end
  after(:each) do
    User.delete_all
    Sensor.delete_all
  end

  subject { page }


  describe "index" do
    describe "with non-admin user"  do
      let(:user) { FactoryBot.create(:user) }
      before do
        2.times { FactoryBot.create(:sensor, user_id: user.id) }
        valid_signin(user)
      end
      it {
        visit sensors_path
        should have_valid_header_and_title('Manage Sensors', 'Manage Sensors')
      }

      it "should list this user's sensors" do
        xhr :get, sensors_path, format: "js"
        pp "Signed in: " + signed_in?.to_s
        pp response.body
        parsed_body = JSON.parse(response.body)
        parsed_body["rows"].count.should == 2
        parsed_body["rows"].each do |row|
          cell = row["cell"]
          cell[cell.length-1].should == user.name
        end
      end

      #it "should pop-up an edit form" do
      #  visit sensors_path
      #  wait_for_ajax
      #  wait_for_dom
      #  pp page.body
      #  page.find(:xpath, "//table[@id='flexSensors']//tr/td").click
      #  page.should have_xpath ("//div[@role='dialog']")
      #end
    end


    describe "with admin user" do
      let(:admin) { FactoryBot.create(:admin) }
       before do
        valid_signin admin
        visit sensors_path
      end

      it { should have_valid_header_and_title('Manage Sensors','Manage Sensors') }

      it "should list this user's sensors" do
        xhr :get, sensors_path, format: "js"
        parsed_body = JSON.parse(response.body)
        parsed_body["rows"].count.should == 6
      end
    end
  end

  describe "with direct accesses" do
    let(:user) { FactoryBot.create(:user) }
    before do
      2.times { FactoryBot.create(:sensor, user_id: user.id, controller: "BasementArduino") }
    end

    describe "with logged out user" do
      it "Should redirect index to home" do
        visit sensors_path
        page.should have_valid_header_and_title(nil, 'Sign in')
      end

      it "Should redirect edit to signin page" do
        visit edit_sensor_path(Sensor.first)
        page.should have_valid_header_and_title(nil, 'Sign in')
      end

      it "Should redirect new to signin page" do
        visit new_sensor_path
        page.should have_valid_header_and_title(nil, 'Sign in')
      end

      it "Should redirect put to signin page" do
        put sensor_path(Sensor.first)
        response.should redirect_to(signin_path)
      end

      it "Should redirect delete to signin page" do
        delete sensor_path(Sensor.first)
        response.should redirect_to(signin_path)
      end

      it "Should redirect post to signin page" do
        post sensors_path
        response.should redirect_to(signin_path)
      end
    end

    describe "with logged in user" do
      before { valid_signin user}

      it "Should redirect edit to welcome page" do
        visit edit_sensor_path(Sensor.first)
        page.should have_valid_header_and_title('Homewatch', '')
      end

      it "Should redirect new to welcome page" do
        visit new_sensor_path
        page.should have_valid_header_and_title('Homewatch', '')
      end

      it "Should redirect put to welcome page" do
        put sensor_path(Sensor.first)
        response.should redirect_to(root_path)
      end

      it "Should redirect delete to welcome page" do
        delete sensor_path(Sensor.first)
        response.should redirect_to(root_path)
      end

      it "Should redirect post to welcome page" do
        post sensors_path
        response.should redirect_to(root_path)
      end
    end

    describe "get config" do
      let(:sensor) { Sensor.first }

      it "should list this controller's sensors, and log if log sent" do
        cntrl = sensor.controller
        key_hash = 0
        cntrl.each_byte do |b|
          key_hash += b
        end
        key_hash *= REQUEST_KEY_MAGIC
        key_hash %= 32768
        pp key_hash
        expect do
          get getconfig_sensors_path, cntrl: cntrl, key: key_hash, log: "Testing"
          pp response.body
        end.to change(Log, :count).by(1)
        expect do
          get getconfig_sensors_path, cntrl: cntrl, key: key_hash
          pp response.body
        end.to change(Log, :count).by(0)
        response.body.should_not be_blank
        parsed_body = JSON.parse(response.body)
        parsed_body.count.should == 8
        parsed_body.each do |row|
          row["id"].should_not be_nil
          row["addressH"].should_not be_nil
          row["addressL"].should_not be_nil
          row["interval"].should_not be_nil
        end

      end
    end


  end
end
