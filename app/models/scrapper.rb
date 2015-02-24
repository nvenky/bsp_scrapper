class Scrapper
    def scrape
        links.each{|f| Downloader.perform_async(f) }
    end
    
    def scrape_sample
        links.take(5).each{|f| Downloader.perform_async(f) }
    end
    
    def links
        m = MetaInspector.new("http://www.betfairpromo.com/betfairsp/prices")
        m.links.raw
    end
end
