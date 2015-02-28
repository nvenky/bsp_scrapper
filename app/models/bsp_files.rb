class BspFiles 
    include Cequel::Record
    #key :id, :uuid, auto: true
    key :filename, :text
    column :processed, :boolean, index: true

    def self.process
        BspFiles.where(processed: false).take(2).each{|bsp_files| ResultParser.perform_async(bsp_files.filename)}
    end
end
