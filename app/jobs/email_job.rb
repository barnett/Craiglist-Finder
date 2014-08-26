class EmailJob < Struct.new(:room_id)
  def perform
    room  = Room.find(room_id)
    gmail = Gmail.new(room.user_id)
    gmail.send_email(room.email) && room.touch(:emailed_at)
  end
end
