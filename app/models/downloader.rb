require 'open-uri'

class Downloader 
    include Sidekiq::Worker
    def perform(file_name)
        dir = 'bsp_files'
        Dir.mkdir(dir) unless Dir.exists?(dir)
        download_file(dir, file_name) unless File.exists?("#{dir}/#{file_name}")
        puts "Completed job for #{file_name}"
    end

    def download_file(dir, file_name)
        open("#{dir}/#{file_name}", 'wb') do |file|
          file << open("http://www.betfairpromo.com/betfairsp/prices/#{file_name}").read
        end
        puts "Downloaded #{file_name}"
    end
end
