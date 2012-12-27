class MonitorWindowsController < ApplicationController

  before_filter :signed_in_user, only: [:new, :create, :index]
  before_filter :correct_or_admin_user,   only: [:edit, :update, :destroy]


  def new
    if request.xhr?
      @monitor_window = MonitorWindow.new
      render partial: 'form'
    else
      redirect_to root_url
    end
  end

  def create
    if request.xhr?
      @monitor_window = MonitorWindow.new(params[:monitor_window])
      @monitor_window.user_id = current_user.id
      if @monitor_window.save
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
      @monitor_window ||= MonitorWindow.find(params[:id])
      render partial: 'form'
    else
      redirect_to root_url
    end
  end

  def update
    if request.xhr?
      @monitor_window = MonitorWindow.find(params[:id])
      if @monitor_window.update_attributes(params[:monitor_window])
        render nothing: true
      else
        puts "Errors found: "
        puts @monitor_window.errors.messages
        render partial: 'form'
      end
    else
      redirect_to root_url
    end
  end

  def index
    respond_to do |format|
      format.html # index.html.erb

      format.js do

        # Get windows for this user
        monitor_windows = MonitorWindow.find_all_by_user_id(current_user.id)

        # Rendering
        render :json => {
            :monitor_windows=>monitor_windows.collect{|mw| {
                :background_color => mw.background_color,
                :monitor_type => mw.monitor_type,
                :name => mw.name,
                :public => mw.public,
                :url => mw.url,
                :width => mw.width,
                :x_axis_auto => mw.x_axis_auto,
                :x_axis_days => mw.x_axis_days,
                :y_axis_max => mw.y_axis_max,
                :y_axis_max_auto => mw.y_axis_max_auto,
                :y_axis_min => mw.y_axis_min,
                :y_axis_min_auto => mw.y_axis_min_auto,
                :monitor_sensors => MonitorSensor.find_all_by_monitor_window_id(mw.id).collect{|ms| {
                    :sensor_id => ms.sensor_id,
                    :legend => ms.legend,
                    :color => ms.color}
                }}
            }
        }.to_json

      end #format.js

    end #respond_to  end
  end

  def getconfig
    @count = 0 if !@count
    @count += 1
    if @count > 1
      raise
    end
    id = params[:id]
    monitor_window = MonitorWindow.find(id)
    name = monitor_window.name
    puts name
    key_hash = params[:key]
    puts key_hash
    if request_key_valid(key_hash, name)
      monitor_sensors = MonitorSensor.find_all_by_monitor_window_id(id)
      render :json => {
          id: id,
          monitor_sensors: monitor_sensors.collect{|ms| {
              :sensor_id => ms.id,
              :legend => ms.legend}
          }
      }.to_json
    else
      render nothing: true
    end
  end

  def destroy
    if request.xhr?
      MonitorWindow.find(params[:id]).destroy
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
      @user = User.find(MonitorWindow.find(params[:id]).user_id)
      redirect_to(root_path) unless (current_user?(@user) || (current_user && current_user.admin?))
    else
      redirect_to signin_url, notice: "Please sign in."
    end
  end

end

