require 'csv'    

class ResultParser
    def initialize(filename)
        @filename = filename
    end

    def parse
        CSV.foreach(@filename, headers: true, 
                    header_converters: lambda {|h| h.strip.downcase.to_sym}, 
                    converters: lambda{|r| r.strip}) do |row|
            next unless numeric?(row[:event_id])
            race_data = row.to_hash 
            market = /bf(prices|grehound)(usa|aus|ire|rsa|uk)?(win|place)?_?\d*/.match(filename)
            raise 'Unknown file name pattern' unless market
            meta_data = {
                         filename: filename, 
                         race_type: market[1] == 'prices' ? 'horse' : market[1],
                         country: (market[2] || 'uk').upcase, 
                         market_type: (market[3] || 'win').upcase,
                         event_selection_id: "#{race_data[:event_id]}-#{race_data[:selection_id]}"
                        }
            RaceResult.create!(race_data.merge(meta_data))
        end 
    end

    def numeric?(num)
        Float(num) != nil rescue false
    end
end
