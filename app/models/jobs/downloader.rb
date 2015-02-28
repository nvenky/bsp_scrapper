require 'open-uri'

class Downloader 
    include Sidekiq::Worker
    def perform(filename)
        dir = 'bsp_files'
        Dir.mkdir(dir) unless Dir.exists?(dir)
        download_file(dir, filename) unless File.exists?("#{dir}/#{filename}")
        BspFiles.create!(filename: filename, processed: false) unless BspFiles.find(filename)
        puts "Completed job for #{filename}"
    end

    def download_file(dir, filename)
        open("#{dir}/#{filename}", 'wb') do |file|
          file << open("http://www.betfairpromo.com/betfairsp/prices/#{filename}").read
        end
        puts "Downloaded #{filename}"
    end
end
