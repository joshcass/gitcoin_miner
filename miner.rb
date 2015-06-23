#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'digest'

class Miner
  def initialize
    @target = Net::HTTP.get(URI.parse("http://git-coin.herokuapp.com/target")).hex
    @message_hex = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF".hex
    @message = nil
  end

  def digest(msg)
    Digest::SHA1.hexdigest msg
  end

  def mine
    time = Time.now
    until @target > @message_hex
      if (time + 3) > Time.now
        @message = @message_hex.to_s
        @message_hex = digest(@message).hex
      else
        get_target
      end
    end
    generate_coin
  end

  def get_target
    @target = Net::HTTP.get(URI.parse("http://git-coin.herokuapp.com/target")).hex
  end

  def generate_coin
    response = Net::HTTP.post_form(URI.parse("http://git-coin.herokuapp.com/hash"), {"message" => "#{@message}", "owner" => "joshcass"})
    @target = eval(response.body).fetch(:new_target).hex
    puts "gitcoin mined!"
    mine
  end
end

Miner.new.mine
