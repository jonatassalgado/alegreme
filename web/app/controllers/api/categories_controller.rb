module Api
	class CategoriesController < ApplicationController

		def index
			@categories = CategoriesGroup.select("categories_groups.*, 'large' as size, COUNT(events.id) as active_events_count").joins(:events).where("events.datetimes[1] > ? AND events.status = 1", DateTime.now).group("categories_groups.id") +
				Category.select("categories.id, categories.name, categories.display_name, categories.url, categories.emoji, 'large' as size, COUNT(events.id) as active_events_count").joins(:events).where("categories.name IN ('show', 'party', 'theatrical_show') AND events.datetimes[1] > ? AND events.status = 1", DateTime.now).group("categories.id") +
				Category.select("categories.id, categories.name, categories.display_name, categories.url, categories.emoji, 'default' as size, COUNT(events.id) as active_events_count").joins(:events).where("categories.name NOT IN ('show', 'party', 'theatrical_show', 'street_fair') AND events.datetimes[1] > ? AND events.status = 1", DateTime.now).group("categories.id")
		end

		private

	end
end
