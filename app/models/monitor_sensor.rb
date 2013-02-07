# == Schema Information
#
# Table name: monitor_sensors
#
#  id                   :integer          not null, primary key
#  sensor_id            :integer
#  monitor_window_id    :integer
#  legend               :string(255)
#  color                :string(255)
#  color_auto           :boolean
#  initial_window_token :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class MonitorSensor < ActiveRecord::Base
  attr_accessible :color, :color_auto, :legend, :monitor_window_id, :sensor_id, :initial_window_token

  belongs_to :monitor_window
  has_many :sensors

  def self.find_all_by_monitor_window(monitor_window_id, initial_token)
    if !monitor_window_id
      MonitorSensor.find_all_by_monitor_window_id(monitor_window_id)
    else
      MonitorSensor.find_all_by_initial_window_token(initial_token)
    end
  end

end
