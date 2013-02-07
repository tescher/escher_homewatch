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
        body = "No measurement since " + last_measurement.created_at.utc.strftime("%a %b %e, %Y, %i:%M %p")
      else
        body = "No measurement yet received."
      end
    else
      alert.value = value
      alert.limit = limit
      alert.save
      alert.reload
      if (value > limit)
        subject += (sensor.trigger_upper_name || sensor.name)
        body = (sensor.trigger_upper_name || (sensor.name + " upper limit reached"))
      else
        subject += (sensor.trigger_lower_name || sensor.name)
        body = (sensor.trigger_lower_name || (sensor.name + " lower limit reached"))
      end
      body += "\n Value: " + value.to_s
      body += "\n Limit: " + limit.to_s
      body += "\n Time: " + alert.created_at.utc.strftime("%a %b %e, %Y, %i:%M %p")
    end
    if alert.email != ""
      puts "Calling mailer"
      alert.send_email(subject, body)
    end
  end

end
