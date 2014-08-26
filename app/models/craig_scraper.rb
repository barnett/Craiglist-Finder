require 'mechanize'

class CraigScraper

  def initialize(user_id)
    @logger = Logger.new('room_finder.log')
    @user   = User.find(user_id)
  end

  def find_rooms
    type = @user.housing_type
    # Create a Mechanize agent
    a = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }

    begin
      page = a.get(@user.url)
    rescue Mechanize::ResponseCodeError => exception
      page = exception.page if exception.response_code == '403'
    ensure
      doc = page.parser
    end

    # Parse each link on the page
    links = doc.css("a").map {|link| link["href"]}.select { |link| (link.match(/\/sfc\/#{type}\/\d+/))? true : false  }.uniq!

    # iterate through each link
    links.each do |post_link|
      begin
        # Create an Room check if you've already contacted it using ActiveRecord create
        href = "http://sfbay.craigslist.org#{post_link}"
        room = @user.rooms.new(href: href)

        if room.valid?
          contact_url = construct_contact_url(room.href)
          room.email = parse_email(contact_url).try(:strip)
          room.save
        else
          @logger.info("Already contacted #{href}")
        end
      rescue Exception => e
        @logger.error(e)
        @logger.error(e.backtrace)
      end
    end
  end

  private

  # Construct the contact page url
  def construct_contact_url(href)
    base_url = href.slice(/\A.+\.org/)
    listing_id = href.slice(/\d+/)
    contact_url = base_url + "/reply/" + listing_id
    return contact_url
  end

  def parse_email(contact_url)
    retries = 0
    begin
      xml_elems = Nokogiri::HTML(open(contact_url))
      email = xml_elems.css("body > div > ul:nth-child(4) > li > a")[0]
      email.try(:text)

    rescue Exception=>e
      puts "ERROR: #{e}"
      retries += 1
      sleep SLEEP_ON_ERROR
      retry unless retries >= RETRY_COUNT
    end
  end

end
