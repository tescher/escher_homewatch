module Utilities

  # checks the validity of a checksum hash
  def request_key_valid(hash, cntrl)
    check_hash = 0
    cntrl.each_byte do |b|
      check_hash += b
    end
    check_hash *= REQUEST_KEY_MAGIC
    check_hash %= 32768
    hash.to_i == check_hash
  end

  # Returns a checksum hash
  def request_key(cntrl)
    check_hash = 0
    cntrl.each_byte do |b|
      check_hash += b
    end
    check_hash *= REQUEST_KEY_MAGIC
    check_hash %= 32768
    check_hash
  end

end
