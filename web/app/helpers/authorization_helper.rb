module AuthorizationHelper

	# if user is logged in, return current_user, else return guest_user
	def current_or_guest_user
		if current_user
			if session[:guest_user_id] && session[:guest_user_id] != current_user.id
				logging_in
				# reload guest_user to prevent caching problems before destruction
				guest_user(with_retry = false).try(:reload).try(:destroy)
				session[:guest_user_id] = nil
			end
			current_user
		else
			guest_user
		end
	end

	# find guest_user object associated with the current session,
	# creating one as needed
	def guest_user(with_retry = true)
		# Cache the value the first time it's gotten.
		@cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

	rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
		session[:guest_user_id] = nil
		guest_user if with_retry
	end


	def authorize_user
		redirect_to feed_path, notice: 'Acesso somente logado' unless current_user
	end

	def authorize_admin
		redirect_to feed_path, notice: 'Acesso somente admins' unless current_user && current_user.admin?
	end


	private

	# called (once) when the user logs in, insert any code your application needs
	# to hand off from guest_user to current_user.
	def logging_in
		unless current_user.personas_assortment_finished?
			current_user.features['psychographic'] = guest_user.features['psychographic']
			current_user.save
		end
	end

	def create_guest_user
		u = User.new({email:    "guest_#{Time.now.to_i}#{rand(100)}@example.com",
		              features: {
				              psychographic: {
						              personas: {
								              primary:    {
										              name:  'hipster',
										              score: '1'
								              },
								              secondary:  {
										              name:  'praieiro',
										              score: '1'
								              },
								              tertiary:   {
										              name:  'underground',
										              score: '1'
								              },
								              quartenary: {
										              name:  'cult',
										              score: '1'
								              },
								              assortment: {
										              finished: false
								              }
						              }
				              }
		              }
		             })
		u.save!(validate: false)
		session[:guest_user_id] = u.id
		u
	end


end