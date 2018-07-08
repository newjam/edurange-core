require 'unix_crypt'
require 'active_support/core_ext/object/blank'

class Password

  ALPHABET = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  DEFAULT_LENGTH = 10

  def Password.random
    Password.new (1..DEFAULT_LENGTH) \
      .map{ ALPHABET.to_a[rand(ALPHABET.length)]} \
      .join
  end

  def initialize password
    raise "Password must not be empty" if password.blank?
    @password = password
  end

  def to_s
    @password
  end

  def inspect
    to_s
  end

  def hash
    UnixCrypt::SHA512.build(@password)
  end

end
