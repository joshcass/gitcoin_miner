require 'net/http'
require 'uri'
require 'digest'
require 'sequel'

class Collector
  def initialize
    @target = "00000009bbdf3c8f256ae651cb8cee5c3e0c9622".hex
    @message_hex = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF".hex
    @message = nil
  end

  def database
    @database ||= Sequel.sqlite("db/messages.sqlite3")
  end

  def digest(msg)
    Digest::SHA1.hexdigest msg
  end

  def collect
    until @target > @message_hex
      @message = @message_hex.to_s
      @message_hex = digest(@message).hex
    end
    collect_message
  end

  def collect_message
    if @message_hex < "0000000013f4289233345df20a03712bf03814b4".hex
      database.from(:messages).insert(:message => "#{@message}", :value => "#{@message_hex}")
      puts "message collected!"
    end
    @message = Time.now.subsec.to_s
    @message_hex = digest(@message).hex
    puts "hex updated!"
    collect
  end
end

Collector.new.collect
