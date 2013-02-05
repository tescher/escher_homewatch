class MeasurementsController < ApplicationController
  def create
    sensor_id = params[:sensor_id].to_i
    value = params[:value].to_f
    @measurement = Measurement.new(sensor_id: sensor_id, value: value, check_value: params[:value], check_hash: params[:key])
    if @measurement.save
      render text: "Filed successfully"
      check_alerts(sensor_id, @measurement.reload.value)
    else
      render text: "Error: \n" + @measurement.errors.full_messages.join("\n")
    end
  end

  def index
    params[:start] = (Time.now - 3600*24*7).utc.strftime("%Y-%m-%d %H:%M:%S %z") if !params[:start]
    params[:end] = (Time.now + 3600).utc.strftime("%Y-%m-%d %H:%M:%S %z") if !params[:end]
    puts params[:start]
    puts params[:end]
    if params[:alerts]
      render :json =>  {
          :id=>"",
          :color=> "red",
          :lines=> {show: false},
          :points=> {show: true},
          :data=> Alert.where("sensor_id = ? and created_at >= ? and created_at <= ?", params[:sensor_id].to_i, params[:start], params[:end]).collect{|m| [m.created_at.to_i*1000, m.value ]}}.to_json
    else
      ms = (params[:monitor_sensor_id].nil? ? nil : MonitorSensor.find(params[:monitor_sensor_id]))
      sensor = Sensor.find(params[:sensor_id])
      render :json =>  {
          :id=>params[:sensor_id],
          :label=> (ms.nil? || ms.legend.empty? ? sensor.name : ms.legend),
          :color=> (ms.nil? || ms.color.empty? ? "" : ms.color),
          :trigger_upper_limit => sensor.trigger_upper_limit,
          :trigger_lower_limit => sensor.trigger_lower_limit,
          :data=> Measurement.where("sensor_id = ? and created_at >= ? and created_at <= ?", params[:sensor_id].to_i, params[:start], params[:end]).collect{|m| [m.created_at.to_i*1000, m.value ]}}.to_json
    end


  end

  private

  def check_alerts(sensor_id, value)

    puts "In check_alerts"

    # Check for absence alerts that need to go out
    Sensor.where("id <> ? and absence_alert", sensor_id).each { |sensor|
      last_measurement = Measurement.order("created_at desc").where("sensor_id = ?", sensor.id).limit(1)[0]
      if last_measurement && ((Time.now.utc.to_i - last_measurement.created_at.utc.to_i) > 24*60*60)
        last_alert = Alert.order("created_at desc").where("sensor_id = ?", sensor.id).limit(1)
        if !last_alert || ((Time.now.utc - last_alert.created_at.to_i) > 24*60*60)
          send_alert(sensor, "", "", last_measurement)
        end
      end
    }

    # Check for limits hit
    sensor = Sensor.find(sensor_id)
    if sensor.trigger_enabled
      last_alert = Alert.order("created_at desc").where("sensor_id = ?", sensor.id).limit(1)[0]
      if !last_alert || ((Time.now.utc.to_i - last_alert.created_at.utc.to_i) > sensor.trigger_delay)
        if sensor.trigger_upper_limit && (value > sensor.trigger_upper_limit)
          send_alert(sensor, value, sensor.trigger_upper_limit, nil)
        end
        if sensor.trigger_lower_limit && (value < sensor.trigger_lower_limit)
          send_alert(sensor, value, sensor.trigger_lower_limit, nil)
        end
      end
    end
  end

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
      UserMailer.alert_email(subject, body, alert.email)
    end
  end

end
