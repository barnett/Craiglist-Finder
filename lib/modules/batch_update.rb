module BatchUpdate

  def self.email
    User.ready.find_each do |user|
      gmail = Gmail.new(user.id)
      user.rooms.need_emails.find_each do |room|
        gmail.email = room.email
        Delayed::Job.enqueue gmail
      end
    end
  end

  def self.scrape
    User.ready.find_each { |u| Delayed::Job.enqueue CraigScraper.new(u.id) }
  end
end
