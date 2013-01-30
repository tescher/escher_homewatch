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

require 'application_helper'

class Measurement < ActiveRecord::Base

  attr_accessor :check_value, :check_hash
  attr_accessible :sensor_id, :value, :check_value, :check_hash
  belongs_to :sensor

  before_create do |measurement|
    sensor = Sensor.find(measurement.sensor_id)
    if sensor
      measurement.value = sensor.scale * measurement.value + sensor.offset
    end
  end

  validates :sensor_id, existence: true
  validates :value, presence: true
  validates :check_hash, presence: true
  validate :valid_hash

  def valid_hash()
    errors.add(:check_hash, "is an invalid hash key") if !request_key_valid(check_hash, check_value)
  end

end
