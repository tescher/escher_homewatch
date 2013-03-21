module Utilities

  # checks the validity of a checksum hash
  def request_key_valid(hash, cntrl)
    check_hash = 0
    cntrl.each_byte do |b|
      check_hash += b
    end
    check_hash *= REQUEST_KEY_MAGIC
    check_hash %= 65536
    hash.to_i == check_hash
  end

  # Returns a checksum hash
  def request_key(cntrl)
    check_hash = 0
    cntrl.each_byte do |b|
      check_hash += b
      pp check_hash
    end
    check_hash *= REQUEST_KEY_MAGIC
    pp check_hash
    check_hash %= 65536
    check_hash
  end

  def check_absence
  # Check for absence alerts that need to go out
    puts "Running check absence"
    Sensor.where("absence_alert").each { |sensor|
      last_measurement = Measurement.order("created_at desc").where("sensor_id = ?", sensor.id).limit(1)[0]
      if last_measurement && ((Time.now.utc.to_i - last_measurement.created_at.utc.to_i) > 24*60*60)
        last_alert = Alert.order("created_at desc").where("sensor_id = ?", sensor.id).limit(1)[0]
        if !last_alert || ((Time.now.utc.to_i - last_alert.created_at.to_i) > 24*60*60)
          send_alert(sensor, "", "", last_measurement)
        end
      end
    }
  end

  def check_purge

    # Check if we should run the clean-ups
    last_purge_key = ConfigKey.find_by_key("last_purge")
    if (!last_purge_key)
      last_purge_key = ConfigKey.new(key: "last_purge", value: 2.days.ago.strftime("%Y-%m-%d %H:%M:%S %z"))
      last_purge_key.save
    end
    if (Time.now.beginning_of_day > DateTime.parse(last_purge_key.value))
      puts "Running purge"
      puts last_purge_key.value
      last_purge_key.value = DateTime.now.strftime("%Y-%m-%d %H:%M:%S %z")
      last_purge_key.save
      puts "created_at < " + 30.days.ago.strftime("%Y-%m-%d %H:%M:%S")
      Measurement.delete_all("created_at < '" + 30.days.ago.strftime("%Y-%m-%d %H:%M:%S")+"'")
      Alert.delete_all("created_at < '" + 30.days.ago.strftime("%Y-%m-%d %H:%M:%S")+"'")
    end
  end

  def check_daily_reports

    # Check if we should run the daily reports
    last_report_key = ConfigKey.find_by_key("last_report")
    if (!last_report_key)
      last_report_key = ConfigKey.new(key: "last_report", value: 2.days.ago.strftime("%Y-%m-%d %H:%M:%S %z"))
      last_report_key.save
    end

    if (Time.now.beginning_of_day > DateTime.parse(last_report_key.value))
      puts "Running reports"
      puts last_report_key.value
      last_report_key.value = DateTime.now.strftime("%Y-%m-%d %H:%M:%S %z")
      last_report_key.save
      date = DateTime.now

      # For each user, who is set to get reports
      User.where("summary_report").each {|user|
        body = "Homewatch Daily Summary Report for " + date.yesterday.strftime("%a %b %e, %Y") + "\n\n"
        # For each sensor
        Sensor.find_all_by_user_id(user.id).each {|sensor|
          body += " \n" + sensor.name + ": "
          last_value = Measurement.order("created_at desc").where("sensor_id = ? and created_at < ?", sensor.id, date.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S")).limit(1)[0]
          if (!last_value)
            body += "No measurement yet received."
          elsif (last_value.created_at < date.yesterday.midnight.in_time_zone(user.time_zone))
            body += "No measurement received yesterday."
          else
            high_value = Measurement.maximum(:value, conditions: ["sensor_id = ? and created_at < ? and created_at >=?", sensor.id, date.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S"),Date.yesterday.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S")])
            low_value = Measurement.minimum(:value, conditions: ["sensor_id = ? and created_at < ? and created_at >=?", sensor.id, date.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S"),Date.yesterday.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S")])
            average_value = Measurement.average(:value, conditions: ["sensor_id = ? and created_at < ? and created_at >=?", sensor.id, date.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S"),Date.yesterday.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S")])
            body += "\n\tAverage: "+average_value.to_s
            body += "\n\tHigh: "+high_value.to_s
            body += "\n\tLow: "+low_value.to_s
            alerts = Alert.where("sensor_id = ? and created_at < ? and created_at >=?", sensor.id, date.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S"),date.yesterday.midnight.in_time_zone(user.time_zone).strftime("%Y-%m-%d %H:%M:%S"))
            if (!alerts)
              body += "No alerts."
            else
              body += "\n\tAlerts:"
              alerts.each {|alert|
                if (alert.value.nil?)
                  body += "\n\t\t"+sensor.name + " absence alert"
                else
                  if (alert.value > alert.limit)
                    body += "\n\t\t"+(sensor.trigger_upper_name.empty? ? (sensor.name + " upper limit reached") : sensor.trigger_upper_name)
                  else
                    body += "\n\t\t"+(sensor.trigger_lower_name.empty? ? (sensor.name + " lower limit reached") : sensor.trigger_lower_name)
                  end
                  body += ", Value: " + alert.value.to_s
                  body += ", Limit: " + alert.limit.to_s
                end
                body += ", Time: " + alert.created_at.in_time_zone(User.find(sensor.user_id).time_zone).strftime("%a %b %e, %Y, %l:%M %p")
              }
            end
          end
        }
        UserMailer.user_report_email("Homewatch Daily Summary",body,user).deliver

      }
    end
  end

end
