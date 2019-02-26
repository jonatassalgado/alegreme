module Alegreme
  module Dates

    def self.get_next_day_occur_human_readable(event)
      return if event.calendars.first.day_time.nil?

      event_date = (event.calendars.first.day_time.to_date)
      difference = (event_date.mjd) - DateTime.now.mjd

      case difference
      when 0
        return "Hoje"
      when 1
        return "Amanhã"
      when 2..6
        case event_date.wday
        when 0
          return "Domingo"
        when 1
          return "Segunda"
        when 2
          return "Terça"
        when 3
          return "Quarta"
        when 4
          return "Quinta"
        when 5
          return "Sexta"
        when 6
          return "Sábado"
        end
      else
        return event_date.strftime("%-d/%-m/%Y")
      end
    end

  end
end
