require 'mechanize'

class CraigScraper
  def initialize(user_id)
    @user = User.find(user_id)

  end

  # iterate through each link
  def perform
    post_links.each { |link| create_room(link) }
  end

  private

  def scraper
    @scraper ||= Mechanize.new do |agent|
      agent.log              = logger
      agent.user_agent_alias = 'Mac Safari'
      agent.robots           = false
    end
  end

  def area
    @area ||= @user.url.match(/:\/\/(?<area>.*).craigslist.org/)['area']
  end

  def city
    @city ||= @user.url.match(/search\/(?<city>.*)\//)['city']
  end

  # Construct the contact page url
  def construct_contact_url(href)
    base_url   = href.slice(/\A.+\.org/)
    listing_id = href.slice(/\d+/)
    base_url + "/reply/" + listing_id
  end

  def create_room(post_link)
    # Create an Room check if you've already contacted it using ActiveRecord create
    href = "http://#{area}.craigslist.org#{post_link}"
    room = @user.rooms.new(href: href)

    if room.valid?
      reply_url  = construct_contact_url(room.href)
      room.email = find_email(reply_url).try(:strip)
      room.save
    else
      logger.info("Already contacted #{href}")
    end
  rescue Exception => e
    logger.error(e)
    logger.error(e.backtrace)
  end

  def find_email(reply_url)
    xml_elems = Nokogiri::HTML(open(reply_url))
    email     = xml_elems.css("body > div > ul:nth-child(4) > li > a")[0]

    return nil unless email.present?

    email.text.strip

  rescue Exception=>e
    defined?(retries) ? retries += 1 : retries = 0
    sleep 5
    retry unless retries >= 3
  end

  def logger
    @logger ||= Rails.logger
  end

  def post_links
    links = scraper.get(@user.url).parser.css("a")
    links.map { |link| link["href"] }
      .select { |link| link.match(/\/#{city}\/#{@user.housing_type}\/\d+/) }
      .uniq!

  rescue Mechanize::ResponseCodeError => exception
    defined?(retries) ? retries += 1 : retries = 1
    sleep(5)
    retry unless retries >= 3
  end

end
