#== Schema Information
#
# Table name: logs
#
#  id         :integer          not null, primary key
#  sensor_id  :integer
#  controller :string
#  content    :string
#  IP_address :string
#  restart_location  :string
#  outage     :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Log < ActiveRecord::Base
  attr_accessible :content, :controller, :sensor_id, :IP_address, :restart_location, :outage

  validates :content, presence: true

  before_create do |log|
    if log.content.include? "CodeRestart"
      log_values = log.content.split('|')
      log.restart_location = log_values[1]
      log.IP_address = log_values[3]
      last_measurement = Measurement.joins(:sensor).where(sensors: { controller: log.controller}).order('created_at DESC').limit(1)[0]
      if last_measurement
        log.outage = DateTime.now - last_measurement.created_at
      end
    end
  end

end
