require 'sequel'
require_relative '../../collector'

Collector.new.database.create_table :messages do
                            primary_key :id
                            String      :message
                            String      :value
end

