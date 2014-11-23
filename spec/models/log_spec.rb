#== Schema Information
#
# Table name: logs
#
#  id         :integer          not null, primary key
#  sensor_id  :integer
#  controller :string
#  content    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

describe Log do
  before do
    @log = Log.new(content:"Log message")

  end

  subject { @log }

  it { should respond_to(:sensor_id) }
  it { should respond_to(:controller) }
  it { should respond_to(:content) }

  it { should be_valid }

  describe "when content is not filled in" do
    before { @log.content = nil }
    it { should_not be_valid }
  end
end
