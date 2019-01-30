json.extract! organizer, :id, :name, :url, :created_at, :updated_at
json.url organizer_url(organizer, format: :json)
