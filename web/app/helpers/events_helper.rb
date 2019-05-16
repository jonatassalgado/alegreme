module EventsHelper

  def limit_name_size(name, limit = 40)
    name.truncate(limit, separator: ' ')
  end

  def limit_place_name_size place_name
    place_name.truncate(22, separator: ' ')
  end

  def format_hour datetime
    DateTime.parse(datetime).strftime("%H:%M")
  end

  def datetime_local(datetime)
    DateTime.parse(datetime).strftime('%Y-%m-%dT%H:%M')
  end

  def get_image_url(event, type = :feed)
    event.image[type].url if event.image && event.image[type].exists?
  end
end
