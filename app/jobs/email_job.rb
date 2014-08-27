class EmailJob < Struct.new(:user_id)
  def perform
    gmail = Gmail.new(user_id)
    gmail.send_emails
  end
end
