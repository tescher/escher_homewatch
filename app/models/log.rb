#== Schema Information
#
# Table name: logs
#
#  id         :integer          not null, primary key
#  sensor_id  :integer
#  controller :string
#  content    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Log < ActiveRecord::Base
  attr_accessible :content, :controller, :sensor_id

  validates :content, presence: true

end
