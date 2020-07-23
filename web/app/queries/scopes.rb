module Scopes

	extend ActiveSupport::Concern

	included do

		UserDecorators::Taste::TASTE_TYPES.each do |taste_type|

			scope "#{UserDecorators::Taste::TASTE_VERBS[taste_type][:past]}_by_user", lambda { |user, opts = {}|
				return Event.all unless user

				opts = {'turn_on': true}.merge(opts)

				if opts[:turn_on] && user
					where(id: user.public_send("taste_#{self.table_name}_#{UserDecorators::Taste::TASTE_VERBS[taste_type][:past]}"))
				else
					all
				end
			}

			scope "not_in_#{UserDecorators::Taste::TASTE_VERBS[taste_type][:past]}", lambda { |user, opts = {}|
				return Event.all unless user

				opts = {'turn_on': true}.merge(opts)
				if opts[:turn_on] && user
					where.not(id: user.public_send("taste_#{self.table_name}_#{UserDecorators::Taste::TASTE_VERBS[taste_type][:past]}"))
				else
					all
				end
			}

		end
	end
end
