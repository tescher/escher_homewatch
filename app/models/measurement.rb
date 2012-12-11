# == Schema Information
#
# Table name: measurements
#
#  id         :integer          not null, primary key
#  sensor_id  :integer
#  value      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Measurement < ActiveRecord::Base

  attr_accessible :sensor_id, :value
  belongs_to :sensor

  before_create do |measurement|
    sensor = Sensor.find(measurement.sensor_id)
    if sensor
      measurement.value = sensor.scale * measurement.value + sensor.offset
    end
  end

  validates :sensor_id, existence: true
  validates :value, presence: true

end
