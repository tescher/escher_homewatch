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

  end


end
