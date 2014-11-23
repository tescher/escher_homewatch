# == Schema Information
#
# Table name: monitor_sensors
#
#  id                :integer          not null, primary key
#  sensor_id         :integer
#  monitor_window_id :integer
#  initial_window_token :string(255)
#  legend            :string(255)
#  color             :string(255)
#  alerts_only       :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

describe MonitorSensor do
  pending "add some examples to (or delete) #{__FILE__}"
end
