require "administrate/field/base"

class CalendarField < Administrate::Field::Base
  def to_s
    data
  end
end
