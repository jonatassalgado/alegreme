class Like < ApplicationRecord
	validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type] }
	validates :sentiment, presence: :true, inclusion: { in: %w(positive negative) }
	validates :likeable_type, presence: :true, inclusion: { in: %w(Event Screening) }
	validate :max_number_of_likes_per_movie, if: -> (l) { l.likeable_type == 'Screening' }

	belongs_to :user
	belongs_to :likeable, polymorphic: true

	def max_number_of_likes_per_movie
		if user.liked_screenings.where(movie_id: likeable.movie.id).exists?
			errors.add(:base, :max_number_of_likes_per_movie, message: "Você só pode salvar uma sessão por filme")
		end
	end
end
