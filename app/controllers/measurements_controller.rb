class MeasurementsController < ApplicationController
  def create
    sensor_id = params[:sensor_id].to_i
    value = params[:value].to_f
    @measurement = Measurement.new(sensor_id: sensor_id, value: value, check_value: params[:value], check_hash: params[:key])
    if @measurement.save
      render text: "Filed successfully"
    else
      render text: "Error: \n" + @measurement.errors.full_messages.join("\n")
    end
  end

  def index
    params[:start] = (Time.now - 3600*24*7).utc.strftime("%Y-%m-%d %H:%M:%S %:z") if !params[:start]
    params[:end] = (Time.now + 3600).utc.strftime("%Y-%m-%d %H:%M:%S %:z") if !params[:end]
    render :json =>  {
        :id=>params[:sensor_id],
        :label=>Sensor.find(params[:sensor_id]).name,
        # :data=> Measurement.where("sensor_id = ?", params[:sensor_id].to_i).collect{|m| {
        :data=> Measurement.where("sensor_id = ? and created_at >= ? and created_at <= ?", params[:sensor_id].to_i, params[:start], params[:end]).collect{|m| [m.value, m.created_at.strftime("%Y-%m-%d %H:%M:%S %:z") ]}}.to_json
    #:ts=>m.created_at.strftime("%Y-%m-%d %H:%M:%S %:z"),
    # :value=>m.value

  end
end
