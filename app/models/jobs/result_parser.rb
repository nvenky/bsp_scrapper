require 'csv'    

class ResultParser
    include Sidekiq::Worker
    
    def perform(filename)
        bsp_file = BspFiles.find_by_filename(filename)
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
                         win_lose: race_data['win_lose'].to_i, #Handle cases where data is 0.0000, 1.0000
                         processed: false
                        }
            begin
             RaceResults.create!(race_data.merge(meta_data))
            rescue Exception
                raise "Failed to insert data - #{race_data.inspect}"
            end

        end 
        bsp_file.update_attributes!(processed: true)
        bsp_file.post_process_file
    end

    def numeric?(num)
        Float(num) != nil rescue false
    end
end
