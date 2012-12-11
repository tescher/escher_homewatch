class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UserConfirmationsHelper
  include SensorsHelper

  unless  Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_404
  end

  private

  def render_404
    render :template => '/public/404', :layout => false, :status => :not_found
  end
end