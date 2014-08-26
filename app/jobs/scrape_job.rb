class ScrapeJob < Struct.new(:uid)
  def perform
    CraigScraper.new(uid).find_rooms 
  end
end
