#!/usr/bin/env ruby
require 'faraday'
require 'digest'
require 'json'

class Miner
  REFRESH_THRESHOLD = 1_000_000

  def initialize
    @target = get_target.hex
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
        @message = @message_hex.to_s + ("a".."z").to_a.sample(5).join
        @message_hex = digest(@message).hex
      else
        @iteration = 0
        @target = get_target.hex
      end
      @iteration += 1
    end
    generate_coin
  end

  def get_target
    Faraday.get("http://git-coin.herokuapp.com/target").body
  end

  def generate_coin
    response = JSON.parse(submit_message)
    @target = response["new_target"].hex
    puts "attempted gitcoin mine! result: #{response["success"]}"
    @message = digest(@message).hex
    mine
  end

  def submit_message
    Faraday.post("http://git-coin.herokuapp.com/hash", {"message" => "#{@message}", "owner" => "joshcass"}).body
  end
end

Miner.new.mine
