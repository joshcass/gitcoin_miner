require 'net/http'
require 'uri'
require 'sequel'

class BetterMiner

  def database
    @database ||= Sequel.sqlite("db/messages.sqlite3")
  end

  def dataset
    database.from(:messages).order(Sequel.desc(:value))
  end

  def mine
    dataset.each do |data|
    Net::HTTP.post_form(URI.parse("http://git-coin.herokuapp.com/hash"), {"message" => "#{data.fetch :message}", "owner" => "joshcass"})
    end
  end
end

BetterMiner.new.mine
