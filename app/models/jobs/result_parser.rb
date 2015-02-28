require 'csv'    

class ResultParser
    include Sidekiq::Worker
    
    def perform(filename)
        dir = 'bsp_files'
        CSV.foreach("#{dir}/#{filename}", headers: true, 
                    header_converters: lambda {|h| h.strip.downcase.to_sym}, 
                    converters: lambda{|r| r.nil? ? nil : r.strip}) do |row|
            next unless numeric?(row[:event_id])
            race_data = row.to_hash 
            market = /bf(prices|greyhound)(usa|aus|ire|rsa|uk)?(win|place)?_?\d*/.match(filename)
            raise 'Unknown file name pattern' unless market
            meta_data = {
                         filename: filename, 
                         race_type: market[1] == 'prices' ? 'horse' : market[1],
                         country: (market[2] || 'uk').upcase, 
                         market_type: (market[3] || 'win').upcase,
                         processed: false
                        }
            RaceResult.create!(race_data.merge(meta_data))
            file_status =BspFiles.find(filename)
            file_status.update_attributes!(processed: true)
        end 
    end

    def numeric?(num)
        Float(num) != nil rescue false
    end
end
