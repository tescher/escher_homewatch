# == Schema Information
#
# Table name: monitor_sensors
#
#  id                :integer          not null, primary key
#  sensor_id         :integer
#  monitor_window_id :integer
#  legend            :string(255)
#  color             :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe MonitorSensors do
  pending "add some examples to (or delete) #{__FILE__}"
end
