require 'sequel'
require_relative '../../miner'

Miner.database.create_table :messages do
                            primary_key :id
                            String      :message
                            String      :value
end

