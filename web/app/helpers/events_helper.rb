module EventsHelper

  def datetime_local(datetime)
    DateTime.parse(datetime).strftime('%Y-%m-%dT%H:%M')
  end
end
