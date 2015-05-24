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
    until @target > @message_hex
      @message = @message_hex.to_s
      @message_hex = digest(@message).hex
    end
    generate_coin
   end

  def generate_coin
    response = Net::HTTP.post_form(URI.parse("http://git-coin.herokuapp.com/hash"), {"message" => "#{@message}", "owner" => "joshcass"})
    @target = eval(response.body).fetch(:new_target).hex
    puts "gitcoin mined!"
    mine
  end
end

Miner.new.mine
