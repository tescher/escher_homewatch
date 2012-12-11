module SensorsHelper

  def request_key_valid(hash, cntrl)
    check_hash = 0
    cntrl.each_byte do |b|
      check_hash += b
    end
    check_hash *= REQUEST_KEY_MAGIC
    hash.to_i == check_hash
  end
end
