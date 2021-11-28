class Like < ApplicationRecord
	validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type] }
	validates :sentiment, presence: :true, inclusion: { in: %w(positive negative) }
	validates :likeable_type, presence: :true, inclusion: { in: %w(Event ScreeningGroup) }
	validate :max_number_of_likes_per_movie, if: -> (l) { l.likeable_type == 'ScreeningGroup' }

	belongs_to :user
	belongs_to :likeable, polymorphic: true

	def max_number_of_likes_per_movie
		if user.liked_screening_groups.where(movie_id: likeable.movie.id).size >= 2
			errors.add(:base, :max_number_of_likes_per_movie, message: "Você só pode salvar 2 sessões por filme")
		end
	end
end
