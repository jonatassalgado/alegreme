namespace :change do
	desc 'Converter screenings to screenings_group'
	task convert_screening_groups: :environment do
		screenings = Screening.all
		counter    = 0

		screenings.find_each do |screening|
			date      = screening.day
			movie_id  = screening.movie_id
			cinema_id = screening.cinema_id

			screening_group = ScreeningGroup.find_by(date: date, cinema_id: cinema_id, movie_id: movie_id)
			if screening_group
				screening_group.screenings << screening
				counter += 1
				puts "#{counter}: (#{screening_group.id}) ScreeningGroup atualizado ~> #{screening_group.cinema_display_name} ~> #{screening_group.title} ~> #{screening_group.screenings.map(&:id)}"
			else
				screening_group = ScreeningGroup.create(date: date, movie_id: movie_id, cinema_id: cinema_id)
				screening_group.screenings << screening
				counter += 1
				puts "#{counter}: (#{screening_group.id}) ScreeningGroup criado ~> #{screening_group.cinema_display_name} ~> #{screening_group.title} ~> #{screening_group.screenings.map(&:id)}"
			end
		end

		Like.where(likeable_type: 'Screening').destroy_all
	end
end