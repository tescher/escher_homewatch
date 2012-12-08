# == Schema Information
#
# Table name: sensor_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  offset     :float
#  scale      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SensorType < ActiveRecord::Base
  attr_accessible :name, :offset, :scale
  has_many  :sensors
end
