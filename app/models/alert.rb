# == Schema Information
#
# Table name: alerts
#
#  id         :integer          not null, primary key
#  sensor_id  :integer
#  value      :float
#  limit      :float
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Alert < ActiveRecord::Base
  attr_accessible :email, :limit, :sensor_id, :value, :created_at
  belongs_to :sensor

  def send_email(subject, body)
    message =  AlertMailer.alert_email(subject, body, self)
    message.deliver
  end


end
