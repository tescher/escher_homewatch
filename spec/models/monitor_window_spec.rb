# == Schema Information
#
# Table name: monitor_windows
#
#  id               :integer          not null, primary key
#  monitor_type     :string(255)
#  name             :string(255)
#  y_axis_min       :integer
#  y_axis_min_auto  :boolean
#  y_axis_max       :integer
#  y_axis_max_auto  :boolean
#  x_axis_days      :integer
#  x_axis_auto      :boolean
#  background_color :string(255)
#  legend           :boolean
#  public           :boolean
#  url              :string(255)
#  width            :string(255)
#  initial_token    :string(255)
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

describe MonitorWindow do

  before do
    @monitor_window = MonitorWindow.new(name: "Example Window")

  end

  subject { @monitor_window }

  it { should respond_to(:name) }
  it { should respond_to(:monitor_type) }
  it { should respond_to(:user_id) }
  it { should respond_to(:y_axis_min) }
  it { should respond_to(:y_axis_min_auto) }
  it { should respond_to(:y_axis_max) }
  it { should respond_to(:y_axis_max_auto) }
  it { should respond_to(:x_axis_days) }
  it { should respond_to(:x_axis_auto) }
  it { should respond_to(:background_color) }
  it { should respond_to(:legend) }
  it { should respond_to(:public) }
  it { should respond_to(:url) }
  it { should respond_to(:width) }
  it { should respond_to(:initial_token) }
  it { should respond_to(:position) }

  it { should be_valid }

  describe "missing name, should be invalid" do
    before do
      @monitor_window.name = ""
     end

    it { should_not be_valid }
  end

  describe "default values" do
    it "should have graph type" do
      @monitor_window.monitor_type.should == :graph
    end
    it "should have dark grey color" do
      @monitor_window.background_color.should == "#ffffff"
    end
    it "should have a legend" do
      @monitor_window.legend.should == true
    end
    it "should not be public" do
      @monitor_window.public.should == false
    end
    it "should have normal width" do
      @monitor_window.width.should == :normal
    end
    it "should have x_axis_auto" do
      @monitor_window.x_axis_auto.should == true
    end
    it "should have y_axis_min_auto" do
      @monitor_window.y_axis_min_auto.should == true
    end
    it "should have y_axis_max_auto" do
      @monitor_window.y_axis_max_auto.should == true
    end
    it "should have an initial_token" do
      @monitor_window.initial_token.should_not be_empty
    end
  end

  describe "should disallow non-enumerated values" do
    it "should enumerate monitor_type" do
      lambda { @monitor_window.monitor_type = :blah }.should raise_error(EnumeratedAttribute::InvalidEnumeration)
    end
    it "should enumerate width" do
      lambda { @monitor_window.width = :blah }.should raise_error(EnumeratedAttribute::InvalidEnumeration)
    end
  end

 end