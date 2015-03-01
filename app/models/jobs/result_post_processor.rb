require 'csv'    

class ResultPostProcessor
    include Sidekiq::Worker
    
    def perform(event_id)
        race_results = RaceResults.where(event_id: event_id)
        sorted_results = race_results.select{|res| !res.bsp.nil?}.sort_by{|res| res.bsp}
        no_of_runners = sorted_results.size
        sorted_results.each_with_index do |result, index|
            result.update_attributes!({
                position: index + 1, 
                position_weight: (index+1).to_f/ no_of_runners, 
                no_of_runners: no_of_runners,
                processed: true
            })
        end
    end

    def numeric?(num)
        Float(num) != nil rescue false
    end
end
