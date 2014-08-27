class ScrapeJob < Struct.new(:uid)
  def perform
    CraigScraper.new(uid).create_rooms 
  end
end
