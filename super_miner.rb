#!/usr/bin/env ruby
require 'uri'
require 'digest'
require 'net/http'

class SuperMiner
  NUM_PROCS = 8
  REFRESH_THRESHOLD = 1000000

  def initialize
    @message_hex = ("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF").hex
    @message = nil
    @iteration = 0
  end

  def digest(msg)
    Digest::SHA1.hexdigest msg
  end

  def mine(i)
    puts "miner #{i} starting to mine!"
    @target = get_target.hex
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
    generate_coin(i)
  end

  def get_target
    Net::HTTP.get(URI.parse("http://git-coin.herokuapp.com/target"))
  end

  def generate_coin(i)
    submit_message
    puts "miner #{i} attempted gitcoin mine!"
    @message = digest(@message).hex
    mine(i)
  end

  def submit_message
    Net::HTTP.post_form(URI.parse("http://git-coin.herokuapp.com/hash"), {"message" => "#{@message}", "owner" => "joshcass"})
  end
end

(1..SuperMiner::NUM_PROCS).map do |i|
  Thread.new do
    SuperMiner.new.mine(i)
  end
end.map(&:join)
