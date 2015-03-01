require 'open-uri'

class Downloader 
    include Sidekiq::Worker
    def perform(filename)
        dir = 'bsp_files'
        Dir.mkdir(dir) unless Dir.exists?(dir)
        download_file(dir, filename) unless File.exists?("#{dir}/#{filename}")
        unless BspFiles.find_by_filename(filename)
           bsp_file = BspFiles.create!(filename: filename, processed: false, post_process: false) 
           bsp_file.process_file
        end
        puts "Completed job for #{filename}"
    end

    def download_file(dir, filename)
        open("#{dir}/#{filename}", 'wb') do |file|
            file << open("http://www.betfairpromo.com/betfairsp/prices/#{filename}").read
        end
        puts "Downloaded #{filename}"
    end
end
