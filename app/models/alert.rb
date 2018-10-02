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
  belongs_to :sensor

  def send_email(subject, body)
    self.email.split(/\s*,\s*/).split(/\s*;\s*/).each { |email|
      message =  AlertMailer.alert_email(subject, body, email)
      message.deliver
    }
  end


end
