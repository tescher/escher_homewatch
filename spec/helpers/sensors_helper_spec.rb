require 'rails_helper'

include SensorsHelper

describe SensorsHelper do

  it "request key should validate on controller name" do
    controller = "Controller Foo"
    key_hash = 0
    controller.each_byte do |b|
      key_hash += b
    end
    key_hash *= REQUEST_KEY_MAGIC
    key_hash %= 65536
    request_key_valid(key_hash, controller).should be_truthy
    request_key_valid(key_hash, "Random Name").should be_falsey
  end

end