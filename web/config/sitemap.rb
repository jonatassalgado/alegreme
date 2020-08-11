# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.alegreme.com"
SitemapGenerator::Sitemap.verbose = true

SitemapGenerator::Sitemap.create do
	# Put links creation logic here.
	#
	# The root path '/' and sitemap index file are added automatically for you.
	# Links are added to the Sitemap in the order they are specified.
	#
	# Usage: add(path, options={})
	#        (default options are used if you don't specify)
	#
	# Defaults: :priority => 0.5, :changefreq => 'weekly',
	#           :lastmod => Time.now, :host => default_host
	#
	# Examples:
	#
	# Add '/articles'
	#
	# add articles_path, :priority => 0.7, :changefreq => 'daily'
	#
	# Add all articles:
	#
	add city_events_path, {:lastmod => DateTime.now, :changefreq => 'daily', :priority => 0.9}

	Event.find_each do |event|
		add event_path(event), {:lastmod => event.updated_at, :changefreq => 'daily', :priority => 0.9}
	end

	Place.find_each do |place|
		add place_path(place), {:lastmod => place.updated_at, :changefreq => 'daily', :priority => 0.8}
	end

	Organizer.find_each do |organizer|
		add organizer_path(organizer), {:lastmod => DateTime.now, :changefreq => 'daily', :priority => 0.8}
	end

	categories = Event::CATEGORIES.dup
	categories.delete_if{|category| ['anúncio', 'outlier'].include? category}.each do |category|
		add category_events_path(category), {:lastmod => DateTime.now, :changefreq => 'daily', :priority => 0.9}
	end
end
