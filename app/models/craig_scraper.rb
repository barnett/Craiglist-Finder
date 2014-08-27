require 'mechanize'

class CraigScraper

  def initialize(user_id)
    @logger = Rails.logger
    @user   = User.find(user_id)
  end

  # iterate through each link
  def find_rooms
    scrape_links.each { |link| create_room(link) }
  end

  private

  def cl_area
    @user.url.match(/http:\/\/(?<area>.*).craigslist.org/)['area']
  end

  def cl_city
    @user.url.match(/search\/(?<city>.*)\//)['city']
  end

  # Construct the contact page url
  def construct_contact_url(href)
    base_url   = href.slice(/\A.+\.org/)
    listing_id = href.slice(/\d+/)
    base_url + "/reply/" + listing_id
  end

  def create_room(post_link)
    # Create an Room check if you've already contacted it using ActiveRecord create
    href = "http://#{cl_area}.craigslist.org#{post_link}"
    room = @user.rooms.new(href: href)

    if room.valid?
      contact_url = construct_contact_url(room.href)
      room.email  = parse_email(contact_url).try(:strip)
      room.save
    else
      @logger.info("Already contacted #{href}")
    end
  rescue Exception => e
    @logger.error(e)
    @logger.error(e.backtrace)
  end

  def parse_email(contact_url)
    retries = 0
    begin
      xml_elems = Nokogiri::HTML(open(contact_url))
      email     = xml_elems.css("body > div > ul:nth-child(4) > li > a")[0]
      email.try(:text)

    rescue Exception=>e
      puts "ERROR: #{e}"
      retries += 1
      sleep 5
      retry unless retries >= 3
    end
  end

  def scrape_links
    agent = Mechanize.new do |agent|
      agent.log              = @logger
      agent.user_agent_alias = 'Mac Safari'
      agent.robots           = false
    end
    retries = 0
    url = @user.url
    begin
      links = agent.get(url)
        .parser
        .css("a")
        .map { |link| link["href"] }
        .select { |link| link.match(/\/#{cl_city}\/#{@user.housing_type}\/\d+/) }
        .uniq!

    rescue Mechanize::ResponseCodeError => exception
      retries += 1
      agent.cookie_jar.clear!
      url += '&_=123456' if retries == 1
      sleep(5)
      retry unless retries >= 3
    end
  end

end
