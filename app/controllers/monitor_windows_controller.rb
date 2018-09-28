class MonitorWindowsController < ApplicationController

  before_filter :signed_in_user, only: [:new, :create, :index, :sort, :temp]
  before_filter :correct_or_admin_user,   only: [:edit, :update, :destroy]


  def new
    if request.xhr?
      @monitor_window = MonitorWindow.new
      puts @monitor_window
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
      format.html #TODO Add a public format also for the public URL

      format.js do

        # Get windows for this user
        monitor_windows = MonitorWindow.find_all_by_user_id(current_user.id, :order => "position, id")

        # Rendering
        render_window_info(monitor_windows)

      end #format.js

    end #respond_to  end
  end

  # Create temporary windows, pass to the client for display in the dashboard, then immediately destroy.
  def temp
    if request.xhr?
      count = (params[:count].nil? ? 1 : params[:count].to_i)
      mws = Array.new()
      for i in 1..count
        @monitor_window = MonitorWindow.new()
        @monitor_window.user_id = current_user.id
        @monitor_window.name = "Temp"
        @monitor_window.width = "small"
        @monitor_window.monitor_type = (params[:monitor_type].nil? ? "graph" : params[:monitor_type].to_s)
        @monitor_window.save
        mws.push(@monitor_window)
      end
      render_window_info(mws)
      for mw in mws
        mw.destroy
      end
    else
      redirect_to root_url
    end

  end

  def sort
    @monitor_windows = MonitorWindow.find_all_by_user_id(current_user.id)
    @monitor_windows.each do |mw|
      mw.position = params["mc"].index(mw.id.to_s) + 1
      mw.save
    end
    render nothing: true
  end

  def public
    respond_to do |format|
      format.html do
        @monitor_window = MonitorWindow.find_by_initial_token(params[:id])
        if @monitor_window && @monitor_window.public
          render 'public'
        else
          redirect_to root_url
        end
      end

      format.js do
        monitor_windows = MonitorWindow.find_all_by_initial_token(params[:id])
        render_window_info(monitor_windows)
      end
    end
  end

  def destroy
    if request.xhr?
      mw = MonitorWindow.find(params[:id])
      MonitorSensor.find_all_by_monitor_window_id(mw.id).each{ |ms| ms.destroy }
      MonitorSensor.find_all_by_initial_window_token(mw.initial_token).each{ |ms| ms.destroy }
      mw.destroy
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

  def render_window_info(monitor_windows)
    # Rendering
    render :json => {
        :monitor_windows=>monitor_windows.collect{|mw| {
            :background_color => mw.background_color,
            :background_color_auto => mw.background_color_auto,
            :id => mw.id,
            :monitor_type => mw.monitor_type,
            :name => mw.name,
            :legend => mw.legend,
            :public => mw.public,
            :url => mw.url,
            :width => mw.width,
            :x_axis_auto => mw.x_axis_auto,
            :x_axis_days => mw.x_axis_days,
            :y_axis_max => mw.y_axis_max,
            :y_axis_max_auto => mw.y_axis_max_auto,
            :y_axis_min => mw.y_axis_min,
            :y_axis_min_auto => mw.y_axis_min_auto,
            :monitor_sensors => MonitorSensor.find_all_by_monitor_window(mw.id, mw.initial_token).collect{|ms|
              sensor_name =  Sensor.find(ms.sensor_id).name
              {
                  :sensor_id => ms.sensor_id,
                  :id => ms.id,
                  :sensor_name => sensor_name,
                  :legend => (ms.legend.empty?) ? sensor_name : ms.legend,
                  :color => ms.color,
                  :color_auto => ms.color_auto,
                  :alerts_only => ms.alerts_only
              }
            },
            :html => render_to_string(partial: 'window_container', locals: { mw_width: mw.width, mw_id: mw.id, mw_name: mw.name, mw_type: mw.monitor_type})
        }}
    }.to_json

  end

end

