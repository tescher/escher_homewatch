# == Schema Information
#
# Table name: alerts
#
#  id         :integer          not null, primary key
#  sensor_id  :integer
#  value      :float
#  limit      :float
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Alert do
  pending "add some examples to (or delete) #{__FILE__}"
end
