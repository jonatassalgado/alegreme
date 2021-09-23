module ScreeningsHelper
	def is_new_screening? screening
		screening.movie&.created_at > (DateTime.now - 48.hours) rescue false
	end
end