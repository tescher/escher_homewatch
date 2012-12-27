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

class MonitorSensor < ActiveRecord::Base
  attr_accessible :color, :legend, :monitor_window_id, :sensor_id

  belongs_to :monitor_window
  has_many :sensors

end
