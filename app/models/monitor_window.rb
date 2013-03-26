# == Schema Information
#
# Table name: monitor_windows
#
#  id               :integer          not null, primary key
#  monitor_type     :string(255)
#  name             :string(255)
#  user_id          :integer
#  y_axis_min       :integer
#  y_axis_min_auto  :boolean
#  y_axis_max       :integer
#  y_axis_max_auto  :boolean
#  x_axis_days      :integer
#  x_axis_auto      :boolean
#  background_color :string(255)
#  background_color_auto :boolean
#  legend           :boolean
#  public           :boolean
#  url              :string(255)
#  width            :string(255)
#  initial_token    :string(255)
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'enumerated_attribute'

class MonitorWindow < ActiveRecord::Base
  enum_attr :monitor_type, %w(^graph table)
  enum_attr :width, %w(^normal wide)
  attr_accessible :background_color, :background_color_auto, :monitor_type, :name, :user_id, :legend, :public, :url, :width, :x_axis_auto, :x_axis_days, :y_axis_max, :y_axis_max_auto, :y_axis_min, :y_axis_min_auto, :initial_token, :position

  belongs_to :user

  after_initialize :default_values

  before_save do |monitor_window|
    monitor_window.monitor_type = :graph if monitor_type.blank?
    monitor_window.background_color_auto = true if background_color.blank?
    monitor_window.legend = true if legend.nil?
    monitor_window.public = false if public.nil?
    monitor_window.width = :normal if width.blank?
    monitor_window.x_axis_auto = true if x_axis_days.nil?
    monitor_window.y_axis_min_auto = true if y_axis_min.nil?
    monitor_window.y_axis_max_auto = true if y_axis_max.nil?
  end

  after_save do |monitor_window|
    monitor_window.reload
    MonitorSensor.find_all_by_initial_window_token(monitor_window.initial_token).each do |ms|
      ms.monitor_window_id = monitor_window.id
      ms.save
    end

  end

  validates :name, presence: true

  private
  def default_values
    self.monitor_type ||= :graph
    self.background_color ||= "#ffffff"
    self.legend = true if self.legend.nil?
    self.public = false if self.public.nil?
    self.width ||= :normal
    self.x_axis_auto = true if self.x_axis_auto.nil?
    self.y_axis_min_auto = true if self.y_axis_min_auto.nil?
    self.y_axis_max_auto = true if self.y_axis_max_auto.nil?
    self.background_color_auto = true if self.background_color_auto.nil?
    if !self.initial_token
      begin
        self.initial_token = SecureRandom.urlsafe_base64
      end while MonitorWindow.exists?(:initial_token => self.initial_token)
    end
  end

end
