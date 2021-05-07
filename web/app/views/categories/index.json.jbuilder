json.array! Category.select("categories.id, categories.details, COUNT(events.id) as active_events_count").joins(:events).where("events.datetimes[1] > ?", DateTime.now).group("categories.id")
