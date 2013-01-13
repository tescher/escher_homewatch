class MonitorSensorsController < ApplicationController

  before_filter :signed_in_user, only: [:new, :create, :index]
  before_filter :correct_or_admin_user,   only: [:edit, :update, :destroy]


  def new
    puts "In new"
    if request.xhr?
      @monitor_sensor = MonitorSensor.new(initial_window_token: params[:initial_window_token])
      @users_sensors = users_sensor_list
      render partial: 'form'
    else
      redirect_to root_url
    end
  end

  def create
    if request.xhr?
      @monitor_sensor = MonitorSensor.new(params[:monitor_sensor])
      if @monitor_sensor.save
        render nothing: true
      else
        puts "Save failed"
        render partial: 'form'
      end
    else
      redirect_to root_url
    end
  end

  def edit
    if request.xhr?
      @monitor_sensor ||= MonitorSensor.find(params[:id])
      @users_sensors = users_sensor_list
      render partial: 'form'
    else
      redirect_to root_url
    end
  end

  def update
    if request.xhr?
      @monitor_sensor = MonitorSensor.find(params[:id])
      if @monitor_sensor.update_attributes(params[:monitor_sensor])
        render nothing: true
      else
        puts "Errors found: "
        puts @monitor_sensor.errors.messages
        render partial: 'form'
      end
    else
      redirect_to root_url
    end
  end

  def index
    respond_to do |format|
      format.js do

        # Get sensors for this window
        monitor_sensors = MonitorSensor.find_all_by_monitor_window(params[:monitor_window_id], params[:initial_window_token])

        # Rendering
        if monitor_sensors
          render :json => {
              :total => monitor_sensors.size,
              :rows=>monitor_sensors.collect{|ms| { :id => ms.id, :cell => [
                  Sensor.find(ms.sensor_id).name,
                  ms.legend,
                  ms.color]
              }}
          }.to_json
        else
          render :json => {}
        end

      end #format.js

    end #respond_to  end
  end


  def destroy
    if request.xhr?
      MonitorSensor.find(params[:id]).destroy
      render nothing: true
    else
      redirect_to root_url
    end
  end



  private

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def correct_or_admin_user
    if signed_in?
      mw_id = MonitorSensor.find(params[:id]).monitor_window_id
      if (mw_id)
        @user = User.find(MonitorWindow.find(MonitorSensor.find(params[:id]).monitor_window_id).user_id)
        redirect_to(root_path) unless (current_user?(@user) || (current_user && current_user.admin?))
      end
    else
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def users_sensor_list
    user = User.find_by_remember_token(cookies[:remember_token])
    if user.admin?
      Sensor.all
    else
      Sensor.find_all_by_user_id(user.id)
    end
  end


end

