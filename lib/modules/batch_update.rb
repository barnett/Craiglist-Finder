module BatchUpdate

  def self.email
    User.ready.find_each do |user|
      user.rooms.need_emails.find_each do |room|
        Delayed::Job.enqueue EmailJob.new(room.id)
      end
    end
  end

  def self.scrape
    User.ready.find_each { |u| Delayed::Job.enqueue ScrapeJob.new(u.id) }
  end
end
