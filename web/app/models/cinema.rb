class Cinema < ApplicationRecord

	extend FriendlyId

	validates :google_maps, uniqueness: true

	has_many :screening_groups, dependent: :destroy
	has_many :movies, -> { distinct }, through: :screening_groups, dependent: :destroy
	has_many :follows, as: :following, dependent: :destroy

	friendly_id :name, use: :slugged

	scope 'active', -> { includes(:screening_groups).where("status = 1 AND screening_groups.date >= ?", DateTime.now).order("cinemas.display_name ASC").references(:screening_groups).distinct }

	enum status: {
		pending:  0,
		active:   1,
		spam:     2,
		archived: 3,
		repeated: 4
	}, _suffix:  true

end