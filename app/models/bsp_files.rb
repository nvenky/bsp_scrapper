class BspFiles 
    include Cequel::Record
    #key :id, :uuid, auto: true
    key :filename, :text, index: true
    column :processed, :boolean, index: true
    column :post_process, :boolean, index: true

    def self.process_files
        BspFiles.where(processed: false).each{|bsp_file| bsp_file.process_file}
    end

    def self.post_process_files
        BspFiles.where(post_process: false).each{|bsp_file| bsp_file.post_process_file}
    end

    def process_file
        ResultParser.perform_async(filename)
    end

    def post_process_file
        event_ids = RaceResults.select(:event_id).where(filename: filename).limit(5000).map(&:event_id).uniq
        event_ids.each{|id| ResultPostProcessor.perform_async(id)}
        update_attributes!(post_process: true)
    end
end
