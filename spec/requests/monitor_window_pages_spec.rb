require 'spec_helper'

describe "MonitorWindowPages" do

  before(:each) do
    3.times { FactoryGirl.create(:user) }
    User.all.each do |user|
      monitor_window = FactoryGirl.create(:monitor_window, user_id: user.id, name: "Window 1")
      2.times {
        sensor = FactoryGirl.create(:sensor, user_id: user.id, controller: "BasementArduino")
        monitor_sensor = FactoryGirl.create(:monitor_sensor, monitor_window_id: monitor_window.id, sensor_id: sensor.id)
        }
    end
  end
  after(:each) do
    User.delete_all
    Sensor.delete_all
    MonitorSensor.delete_all
    MonitorWindow.delete_all
  end

  subject { page }


  describe "index" do
    describe "with non-admin user"  do
      let(:user) { FactoryGirl.create(:user) }
      before do
        monitor_window = FactoryGirl.create(:monitor_window, user_id: user.id, name: "Window 1")
        2.times {
          sensor = FactoryGirl.create(:sensor, user_id: user.id, controller: "BasementArduino")
          monitor_sensor = FactoryGirl.create(:monitor_sensor, monitor_window_id: monitor_window.id, sensor_id: sensor.id)
        }
        valid_signin(user)
      end
      it {
        visit monitor_windows_path
        should have_valid_header_and_title('Monitors', 'Monitors')
      }

      it "should list this user's monitors and sensors" do
        get monitor_windows_path, format: "js"
        pp response.body
        parsed_body = JSON.parse(response.body)
        parsed_body["monitor_windows"].count.should == 1
        parsed_body["monitor_windows"].each do |mw|
          mw["monitor_sensors"].count.should == 2
          mw["monitor_sensors"].each do |ms|
            sensor_id = ms["sensor_id"]
            Sensor.find(sensor_id).user_id.should == user.id
          end
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


  end

  describe "with direct accesses" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      monitor_window = FactoryGirl.create(:monitor_window, user_id: user.id, name: "Window 1")
      2.times {
        sensor = FactoryGirl.create(:sensor, user_id: user.id, controller: "BasementArduino")
        monitor_sensor = FactoryGirl.create(:monitor_sensor, monitor_window_id: monitor_window.id, sensor_id: sensor.id)
      }
    end

    describe "with logged out user" do
      it "Should redirect index to home" do
        visit monitor_windows_path
        page.should have_valid_header_and_title(nil, 'Sign in')
      end

      it "Should redirect edit to signin page" do
        visit edit_monitor_window_path(MonitorWindow.first)
        page.should have_valid_header_and_title(nil, 'Sign in')
      end

      it "Should redirect new to signin page" do
        visit new_monitor_window_path
        page.should have_valid_header_and_title(nil, 'Sign in')
      end

      it "Should redirect put to signin page" do
        put monitor_window_path(MonitorWindow.first)
        response.should redirect_to(signin_path)
      end

      it "Should redirect delete to signin page" do
        delete monitor_window_path(MonitorWindow.first)
        response.should redirect_to(signin_path)
      end

      it "Should redirect post to signin page" do
        post monitor_windows_path
        response.should redirect_to(signin_path)
      end

      it "Should redirect get of sensors to signin page" do
        get monitor_sensors_path
        response.should redirect_to(signin_path)
      end
    end

    describe "with logged in user" do
      before { valid_signin user}

      it "Should redirect edit to welcome page" do
        visit edit_monitor_window_path(MonitorWindow.first)
        page.should have_valid_header_and_title('Homewatch', '')
      end

      it "Should redirect new to welcome page" do
        visit new_monitor_window_path
        page.should have_valid_header_and_title('Homewatch', '')
      end

      it "Should redirect put to welcome page" do
        put monitor_window_path(MonitorWindow.first)
        response.should redirect_to(root_url)
      end

      it "Should redirect delete to welcome page" do
        delete monitor_window_path(MonitorWindow.first)
        response.should redirect_to(root_url)
      end

      it "Should redirect post to welcome page" do
        post monitor_windows_path
        response.should redirect_to(root_url)
      end
    end
  end
end
