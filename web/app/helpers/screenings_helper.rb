module ScreeningsHelper
	def is_new_screening? screening
		screening.movie&.created_at > (DateTime.now - 5.days) rescue false
	end
end