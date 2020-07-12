module Scopes

	extend ActiveSupport::Concern

	included do

	scope 'saved_by_user', lambda { |user, opts = {}|
		return Event.all unless user

		opts = {'turn_on': true}.merge(opts)

		if opts[:turn_on] && user
			where(id: user.public_send("taste_#{self.table_name}_saved"))
		else
			all
		end
	}

  scope 'not_in_saved', lambda { |user, opts = {}|
	  return Event.all unless user

	  opts = {'turn_on': true}.merge(opts)
    if opts[:turn_on] && user
      where.not(id: user.public_send("taste_#{self.table_name}_saved"))
    else
      all
    end
  }

	end
end
