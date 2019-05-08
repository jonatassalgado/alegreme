module EventsHelper

  def limit_name_size name
    name.truncate(40, separator: ' ')
  end

  def limit_place_name_size place_name
    place_name.truncate(22, separator: ' ')
  end

  def datetime_local(datetime)
    DateTime.parse(datetime).strftime('%Y-%m-%dT%H:%M')
  end
end
