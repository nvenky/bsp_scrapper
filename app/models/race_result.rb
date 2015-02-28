class RaceResult 
    include Cequel::Record
    #key :id, :uuid, auto: true
    #key :event_selection_id, :text, index: true
    key :event_id, :int, index: true
    key :selection_id, :int, index: true
    column :filename, :text
    column :country, :text
    column :race_type, :text
    column :market_type, :text
    column :menu_hint, :text
    column :event_name, :text
    column :event_dt, :timestamp
    column :selection_name, :text
    column :win_lose, :int
    column :bsp, :double, index: true
    column :position, :int, index: true
    column :no_of_runners, :int, index: true
    column :position_weight, :double, index: true
    column :ppwap, :double
    column :morningwap, :double
    column :ppmax, :double
    column :ppmin, :double
    column :ipmax, :double
    column :ipmin, :double
    column :morningtradedvol, :double
    column :pptradedvol, :double
    column :iptradedvol, :double
    column :processed, :boolean, index: true, default: false


    def self.post_process
        event_ids = RaceResult.select(:event_id).where(processed: false).limit(5000).map(&:event_id).uniq
        event_ids.each{|id| ResultPostProcessor.perform_async(id)}
    end
end
