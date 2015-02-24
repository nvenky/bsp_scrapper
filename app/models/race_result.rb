class RaceResult 
    include Cequel::Record
    key :id, :uuid, auto: true
    column :filename, :text
    column :country, :text
    column :race_type, :text
    column :market_type, :text
    column :event_selection_id, :text, index: true
    column :event_id, :int
    column :menu_hint, :text
    column :event_name, :text
    column :event_dt, :timestamp
    column :selection_id, :int
    column :selection_name, :text
    column :win_lose, :boolean
    column :bsp, :double
    column :ppwap, :double
    column :morningwap, :double
    column :ppmax, :double
    column :ppmin, :double
    column :ipmax, :double
    column :ipmin, :double
    column :morningtradedvol, :double
    column :pptradedvol, :double
    column :iptradedvol, :double
end
