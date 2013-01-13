class MeasurementsController < ApplicationController
  def create
    sensor_id = params[:sensor_id].to_i
    value = params[:value].to_f
    @measurement = Measurement.new(sensor_id: sensor_id, value: value)
    if @measurement.save
      render text: "Filed successfully"
    else
        render text: "Error: \n" + @measurement.errors.full_messages.join("\n")
    end
  end

  def index
    params[:start] = (Time.now - 3600*24*7).strftime("%Y-%m-%d %H:%M:%S %:z") if !params[:start]
    params[:end] = (Time.now + 3600).strftime("%Y-%m-%d %H:%M:%S %:z") if !params[:end]
    render :json =>  {
        :id=>params[:sensor_id],
        :label=>Sensor.find(params[:sensor_id]).name,
        :data=> Measurement.where("sensor_id = ? and created_at >= ? and created_at <= ?", params[:sensor_id].to_i, params[:start], params[:end]).collect{|m| {
             :ts=>m.created_at,
             :value=>m.value}}}.to_json
  end
end
