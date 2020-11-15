class LeftSidebar::MyAgendaComponent < ViewComponentReflex::Component

  attr_accessor :view_context, :options

  def initialize(events:, start_date: Date.today, user:)
    @start_date = start_date
    @events     = events
    @indicators = events.map(&:start_time)
    @user       = user
    @filter     = false

    @params  = {}
    @options = {}

    @params.merge!(@options.fetch(:params, {}))
  end

  def prev_month
    @start_date = date_range.first - 1.day
  end

  def next_month
    @start_date = date_range.last + 1.day
  end

  def in_day
    @filter     = true
    @start_date = element['data-day'].to_date
    @events     = liked_events.in_day(@start_date)
  end

  def clear_filter
    @filter     = false
    @start_date = Date.today
    @events     = liked_events
  end

  def update
    @events     = liked_events
    @indicators = @events.map(&:start_time)
  end

  def td_classes_for(day)
    today = Date.current

    td_class = ['day rounded-full cursor-pointer hover:bg-green-100 hover:text-green-500']
    td_class << "wday-#{day.wday.to_s}"
    td_class << 'today' if today == day
    td_class << 'past' if today > day
    td_class << 'future' if today < day
    td_class << 'start-date' if day.to_date == start_date.to_date && @filter
    td_class << 'prev-month' if start_date.month != day.month && day < start_date
    td_class << 'next-month' if start_date.month != day.month && day > start_date
    td_class << 'current-month' if start_date.month == day.month
    td_class << 'has-events' if sorted_events.fetch(day, []).any?

    td_class
  end

  def tr_classes_for(week)
    today    = Date.current
    tr_class = ['week']
    tr_class << 'current-week' if week.include?(today)

    tr_class
  end

  def date_range
    (start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week).to_a
  end

  private

  def liked_events
    @user&.liked_events&.not_ml_data&.active&.order_by_date
  end

  def partial_name
    @options[:partial] || self.class.name.underscore
  end

  def attribute
    options.fetch(:attribute, :start_time).to_sym
  end

  def end_attribute
    options.fetch(:end_attribute, :end_time).to_sym
  end

  def start_date_param
    options.fetch(:start_date_param, :start_date).to_sym
  end

  def sorted_events
    begin
      events = @events.reject { |e| e.send(attribute).nil? }.sort_by(&attribute)
      group_events_by_date(events)
    end
  end

  def group_events_by_date(events)
    events_grouped_by_date = {}

    events.each do |event|
      event_start_date = event.send(attribute).to_date
      event_end_date   = (event.respond_to?(end_attribute) && !event.send(end_attribute).nil?) ? event.send(end_attribute).to_date : event_start_date
      (event_start_date..event_end_date.to_date).each do |enumerated_date|
        events_grouped_by_date[enumerated_date] = [] unless events_grouped_by_date[enumerated_date]
        events_grouped_by_date[enumerated_date] << event
      end
    end

    events_grouped_by_date
  end

  def start_date
    if @start_date
      @start_date
    elsif options.has_key?(:start_date)
      options.fetch(:start_date).to_date
    else
      view_context.params.fetch(start_date_param, Date.current).to_date
    end
  end

  def end_date
    date_range.last
  end

  def additional_days
    options.fetch(:number_of_days, 4) - 1
  end

end