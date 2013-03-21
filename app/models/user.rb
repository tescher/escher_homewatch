# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_digest        :string(255)
#  remember_token         :string(255)
#  admin                  :boolean          default(FALSE)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  state                  :string(255)
#  confirmation_token     :string(255)
#  time_zone              :string(255)
#  summary_report         :boolean
#

require 'state_machine'

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :time_zone, :summary_report
  has_secure_password
  has_many :sensors
  has_many :monitor_windows

  before_create {
    generate_token(:remember_token)
    self.time_zone = DEFAULT_TIME_ZONE
  }
  before_save do |user|
                  user.email = email.downcase
                  if (!user.password.blank?)     # Password reset, get rid of the token
                    user.password_reset_token = ""
                  end
                  if (user.time_zone.blank?)     # Default time_zone
                    user.time_zone = DEFAULT_TIME_ZONE
                  end
  end


  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, :presence =>true, :confirmation => true, :length => { :within => 6..40 }, :on => :create
  validates :password, :confirmation => true, :length => { :within => 6..40 }, :on => :update, :unless => lambda{ |user| (user.password.blank? && (!user.password_reset_token.blank? || !user.confirmation_token.blank?)) }
  # validates :password, presence: true, length: { minimum: 6 }
  # validates :password_confirmation, presence: true

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def send_confirmation
    generate_token(:confirmation_token)
    save!
    UserMailer.user_confirmation(self).deliver
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  state_machine :state, :initial => :pended do
    event :activate do
      transition all => :active
    end
    event :pend do
      transition all => :pended
    end
  end



end
