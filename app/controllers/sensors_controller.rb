class SensorsController < ApplicationController

  before_filter :signed_in_user, only: [:new, :create, :index]
  before_filter :correct_or_admin_user,   only: [:edit, :update, :destroy]


  def new
    if request.xhr?
      @sensor = Sensor.new
      render partial: 'form'
    else
      redirect_to root_url
    end
  end

  def create
    if request.xhr?
      @sensor = Sensor.new(params[:sensor])
      @sensor.user_id = current_user.id
      if @sensor.save
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
      @sensor ||= Sensor.find(params[:id])
      render partial: 'form'
    else
      redirect_to root_url
    end
  end

  def update
    if request.xhr?
      @sensor = Sensor.find(params[:id])
      if @sensor.update_attributes(params[:sensor])
        render nothing: true
      else
        puts "Errors found: "
        puts @sensor.errors.messages
        render partial: 'form'
      end
    else
      redirect_to root_url
    end
  end

  def index
    respond_to do |format|
      format.html # index.html.erb

      # With the Flexigrid, we need to render Json data
      format.js do

        # Get sensors for this user, or all for admin
        if !current_user.admin?
          sensors = Sensor.find_all_by_user_id(current_user.id)
        else
          sensors = Sensor.all
        end

        # Rendering
        render :json => {
            :total=>sensors.size,
            :rows=>sensors.collect{|r| {:id=>r.id, :cell=>[
                                        r.name,
                                        r.controller,
                                        r.trigger_enabled,
                                        r.trigger_upper_limit,
                                        r.trigger_lower_limit,
                                        r.trigger_email,
                                        r.absence_alert,
                                        User.find_by_id(r.user_id).name]}},
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
    cntrl = params[:cntrl]
    key_hash = params[:key]
    if request_key_valid(key_hash, cntrl)
      sensors = Sensor.find_all_by_controller(cntrl)
      render :json =>
          sensors.collect{|s| {
              :id => s.id,
              :addressH => s.addressH,
              :addressL => s.addressL,
              :interval => s.interval}}
    else
      render nothing: true
    end
  end

  def destroy
    if request.xhr?
      Sensor.find(params[:id]).destroy
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
      @user = User.find(Sensor.find(params[:id]).user_id)
      redirect_to(root_path) unless (current_user?(@user) || (current_user && current_user.admin?))
    else
      redirect_to signin_url, notice: "Please sign in."
    end
  end

end

