module EventsHelper
  def limit_name_size(name, limit = 40)
    name.truncate(limit, separator: " ") if name
  end

  def limit_description_size(name, limit = 140)
    strip_tags(name).truncate(limit, separator: " ") if name
  end

  def limit_place_name_size(place_name)
    place_name.truncate(22, separator: " ")
  end

  def format_hour(datetime)
    DateTime.parse(datetime).strftime("%H:%M")
  end

  def datetime_local(datetime)
    DateTime.parse(datetime).strftime("%Y-%m-%dT%H:%M")
  end

  def get_image_url(event, type = :feed)
    begin 
      event.image[type].url if event.image && event.image[type].exists?
    rescue
      ""
    end
  end

  def round_score(score, precision = 6)
    return 0.0 if score.nil?
    return score.to_f.round(precision) if score.is_a? String
    score.round(precision) 
  end

  def get_score_scale_color(scale = 1.0)
    rounded_scale = scale.to_f.round(1)

    case rounded_scale
    when 1.0 then '#5ecf80'
    when 0.9 then '#71bc7e'
    when 0.8 then '#7ab37d'
    when 0.7 then '#84a97c'
    when 0.6 then '#8da07b'
    when 0.5 then '#97977b'
    when 0.4 then '#a08d7a'
    when 0.3 then '#bc7177'
    when 0.2 then '#bc7177'
    when 0.1 then '#cf5e75'
    when 0.0 then '#cf5e75'
    end
  end
end
