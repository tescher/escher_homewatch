module MeasurementsHelper
  def send_alert(sensor, value, limit, last_measurement)
    alert = Alert.new()
    alert.sensor_id = sensor.id
    alert.email = sensor.trigger_email
    subject = "Homewatch: "
    if (value == "")
      alert.save
      subject += sensor.name + " absence alert"
      if last_measurement
        body = "No measurement since " + last_measurement.created_at.in_time_zone(User.find(sensor.user_id).time_zone).strftime("%a %b %e, %Y, %l:%M %p")
      else
        body = "No measurement yet received."
      end
    else
      alert.value = value
      alert.limit = limit
      alert.save
      alert.reload
      if (value > limit)
        subject += (sensor.trigger_upper_name.empty? ? sensor.name : sensor.trigger_upper_name)
        body = (sensor.trigger_upper_name.empty? ? (sensor.name + " upper limit reached") : sensor.trigger_upper_name)
      else
        subject += (sensor.trigger_lower_name.empty? ? sensor.name : sensor.trigger_lower_name)
        body = (sensor.trigger_lower_name.empty? ? (sensor.name + " lower limit reached") : sensor.trigger_lower_name)
      end
      body += "\nValue: " + value.to_s
      body += "\nLimit: " + limit.to_s
      body += "\nTime: " + alert.created_at.in_time_zone(User.find(sensor.user_id).time_zone).strftime("%a %b %e, %Y, %l:%M %p")
      body += "\n\nTo pause alerts go to " + url_for([sensor, action: 'pause'])
    end
    if alert.email != ""
      puts "Calling mailer"
      alert.send_email(subject, body)
    end
  end

end
