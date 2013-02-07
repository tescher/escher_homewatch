module MeasurementsHelper
  def send_alert(sensor, value, limit, last_measurement)
    alert = Alert.new()
    alert.sensor_id = sensor.id
    alert.email = sensor.trigger_email
    subject = "Homewatch Alert from sensor "+sensor.name
    if (value == "")
      alert.save
      if last_measurement
        body = "No measurement since " + last_measurement.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z")
      else
        body = "No measurement yet received."
      end
    else
      alert.value = value
      alert.limit = limit
      alert.save
      body = "Limit reached by sensor: Value: " + value.to_s + " Limit: " + limit.to_s + " Time: " + Time.now.utc.strftime("%Y-%m-%d %H:%M:%S %z")
    end
    if alert.email != ""
      puts "Calling mailer"
      alert.send_email(subject, body)
    end
  end

end
