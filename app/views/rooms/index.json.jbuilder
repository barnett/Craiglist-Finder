json.array!(@rooms) do |room|
  json.extract! room, :id, :href, :emailed_at
  json.url room_url(room, format: :json)
end
