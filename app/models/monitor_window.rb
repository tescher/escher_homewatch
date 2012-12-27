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
#  public           :boolean
#  url              :string(255)
#  width            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'enumerated_attribute'

class MonitorWindow < ActiveRecord::Base
  enum_attr :monitor_type, %w(^graph table)
  enum_attr :width, %w(^normal wide)
  attr_accessible :background_color, :monitor_type, :name, :user_id, :public, :url, :width, :x_axis_auto, :x_axis_days, :y_axis_max, :y_axis_max_auto, :y_axis_min, :y_axis_min_auto

  belongs_to :user

  after_initialize :default_values

  before_save do |monitor_window|
    monitor_window.monitor_type = :graph if monitor_type.blank?
    monitor_window.background_color = "404040" if background_color.blank?
    monitor_window.public = false if public.blank?
    monitor_window.width = :normal if width.blank?
    monitor_window.x_axis_auto = true if x_axis_days.blank?
    monitor_window.y_axis_min_auto = true if y_axis_min.blank?
    monitor_window.y_axis_max_auto = true if y_axis_max.blank?
  end

  validates :name, presence: true

  private
  def default_values
    self.monitor_type = :graph
    self.background_color = "404040"
    self.public = false
    self.width = :normal
    self.x_axis_auto = true
    self.y_axis_min_auto = true
    self.y_axis_max_auto = true
  end
end
