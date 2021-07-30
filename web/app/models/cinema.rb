class Cinema < ApplicationRecord

	extend FriendlyId

	validates :google_maps, uniqueness: true

	has_many :screenings, dependent: :destroy
	has_many :movies, -> { distinct }, through: :screenings, dependent: :destroy
	has_many :follows, as: :following, dependent: :destroy

	friendly_id :name, use: :slugged

	scope 'active', -> { includes(:screenings).where("status = 1 AND screenings.day >= ?", DateTime.now).order("cinemas.display_name ASC").references(:screenings).distinct }

	enum status: {
		pending:  0,
		active:   1,
		spam:     2,
		archived: 3,
		repeated: 4
	}, _suffix:  true

end