# == Schema Information
#
# Table name: sensors
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  sensor_type_id      :integer
#  user_id             :integer
#  group               :string(255)
#  controller          :string(255)
#  addressH            :integer
#  addressL            :integer
#  offset              :float
#  scale               :float
#  interval            :integer
#  trigger_upper_limit :float
#  trigger_lower_limit :float
#  trigger_delay       :integer
#  trigger_email       :string(255)
#  trigger_enabled     :boolean
#  absence_alert       :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  trigger_lower_name  :string(255)
#  trigger_upper_name  :string(255)
#

class Sensor < ActiveRecord::Base

  attr_accessible :absence_alert, :addressH, :addressL, :controller, :group, :interval, :name, :offset, :scale, :sensor_type_id, :trigger_delay, :trigger_email, :trigger_enabled, :trigger_lower_limit, :trigger_upper_limit, :user_id, :trigger_lower_name, :trigger_upper_name
  belongs_to :user
  belongs_to :sensor_type
  belongs_to :monitor_sensors
  has_many :measurements
  has_many :alerts

  after_initialize :default_values


  before_save do |sensor|
    sensor.trigger_email = trigger_email.downcase if !trigger_email.blank?
    sensor.interval ||= 60
    sensor.trigger_delay ||= 600
  end

  validates :name, presence: true, length: { maximum: 50 }
  validates :addressH, presence: true
  validates :addressL, presence: true
  validates :offset, presence: true
  validates :scale, presence: true
  validates :sensor_type_id, existence: true
  validates :user_id, existence: true
  validates :controller, presence: true, length: { maximum: 50 }
  validates :trigger_email, format: { with: VALID_EMAIL_REGEX }, allow_blank: true
  validate :no_duplicate_addresses

  def no_duplicate_addresses
    dup = Sensor.find_by_addressH_and_addressL(addressH, addressL)
    errors.add(:addressH, "is a duplicate sensor address, already in use") if dup && (dup != self)
  end

  private
  def default_values
    self.interval ||= 60
    self.offset ||= 0.0
    self.scale ||= 1.0
    self.trigger_delay ||= 600
  end

  end
