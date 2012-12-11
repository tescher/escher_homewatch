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
    params[:start] = "1970-01-01 00:00:00" if !params[:start]
    params[:end] = (Time.now + 3600).strftime("%Y-%m-%d %H:%M:%S %:z") if !params[:end]
    render :json =>  {
        :label=>Sensor.find_by_id(params[:sensor_id]).name,
        :id=>params[:sensor_id],
        :data=> Measurement.where("sensor_id = ?",
                                   params[:sensor_id].to_i).collect{|m| {
             :t=>m.created_at,
             :v=>m.value}}}.to_json
  end
end
