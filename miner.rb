#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'digest'

class Miner
  REFRESH_THRESHOLD = 1_000_000

  def initialize
    @target = get_target
    @message_hex = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF".hex
    @message = nil
    @iteration = 0
  end

  def digest(msg)
    Digest::SHA1.hexdigest msg
  end

  def mine
    until @target > @message_hex
      if @iteration < REFRESH_THRESHOLD
        @message = @message_hex.to_s
        @message_hex = digest(@message).hex
      else
        @iteration = 0
        @target = get_target
      end
      @iteration += 1
    end
    generate_coin
  end

  def get_target
    Net::HTTP.get(URI.parse("http://git-coin.herokuapp.com/target")).hex
  end

  def generate_coin
    response = Net::HTTP.post_form(URI.parse("http://git-coin.herokuapp.com/hash"), {"message" => "#{@message}", "owner" => "joshcass"})
    @target = eval(response.body).fetch(:new_target).hex
    puts "gitcoin mined!"
    mine
  end
end

Miner.new.mine
