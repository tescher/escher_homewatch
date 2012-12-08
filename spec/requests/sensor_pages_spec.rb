require 'spec_helper'

describe "SensorPages" do

  before(:each) do
    3.times { FactoryGirl.create(:user) }
    User.all.each do |user|
      2.times { FactoryGirl.create(:sensor, user_id: user.id) }
    end
  end
  after(:each) do
    User.delete_all
    Sensor.delete_all
  end

  subject { page }


  describe "index" do
    describe "with non-admin user", js: true  do
      let(:user) { FactoryGirl.create(:user) }
      before do
        2.times { FactoryGirl.create(:sensor, user_id: user.id) }
        valid_signin(user)
        visit sensors_path
      end
      it { should have_valid_header_and_title('Manage Sensors', 'Manage Sensors') }

      it "should list this user's sensors" do
        get sensors_path, format: "js"
        parsed_body = JSON.parse(response.body)
        parsed_body["rows"].count.should == 2
        parsed_body["rows"].each do |row|
          cell = row["cell"]
          cell[cell.length-1].should == user.id
        end
      end

      it "should pop-up an edit form" do
        page.find(:xpath, "//table[@id='flexSensors']//tr/td").click
        page.should have_xpath ("//div[@role='dialog']")
      end
    end


    describe "with admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
       before do
        valid_signin admin
        visit sensors_path
      end

      it { should have_valid_header_and_title('Manage Sensors','Manage Sensors') }

      it "should list this user's sensors" do
        get sensors_path, format: "js"
        parsed_body = JSON.parse(response.body)
        parsed_body["rows"].count.should == 6
      end
    end
  end

  describe "with direct accesses" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      2.times { FactoryGirl.create(:sensor, user_id: user.id) }
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
        response.should redirect_to(root_url)
      end

      it "Should redirect delete to welcome page" do
        delete sensor_path(Sensor.first)
        response.should redirect_to(root_url)
      end

      it "Should redirect post to welcome page" do
        post sensors_path
        response.should redirect_to(root_url)
      end



    end

  end
end
