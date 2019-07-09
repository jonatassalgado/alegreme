class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
	devise :omniauthable, omniauth_providers: [:google_oauth2]

	acts_as_follower

	include UserDecorators::Following

	def favorited_events
		if self && !self.taste_events_saved.empty?
			Event.saved_by_user(self).active.order_by_date.uniq
		else
			[]
		end
	end

	# def insensitive_attributes
	#   attributes.slice(:id,)
	# end

	def name
		features['demographic']['name'] if features['demographic']
	end

	def name=(value)
		features['demographic']['name'] = name
	end

	def picture
		features['demographic']['picture'] if features['demographic']
	end

	def picture=(value)
		features['demographic']['picture'] = picture
	end

	def demographic=(values)
		raise ArgumentError unless values.is_a? Hash
		features['demographic'].update values
	end

	def personas_name
		features['psychographic']['personas'].map { |persona| persona[1]['name'] }.compact
	end

	def personas_primary_name
		features['psychographic']['personas']['primary']['name'] if features['psychographic']
	end

	def personas_primary_name=(value)
		features['psychographic']['personas']['primary']['name'] = value
	end

	def personas_secondary_name
		features['psychographic']['personas']['secondary']['name'] if features['psychographic']
	end

	def personas_secondary_name=(value)
		features['psychographic']['personas']['secondary']['name'] = value
	end

	def personas_primary_score
		features['psychographic']['personas']['primary']['score'] if features['psychographic']
	end

	def personas_primary_score=(value)
		features['psychographic']['personas']['primary']['score'] = value
	end

	def personas_secondary_score
		features['psychographic']['personas']['secondary']['score'] if features['psychographic']
	end

	def personas_secondary_score=(value)
		features['psychographic']['personas']['secondary']['score'] = value
	end

	def personas_tertiary_name
		features['psychographic']['personas']['tertiary']['name'] if features['psychographic']
	end

	def personas_tertiary_name=(value)
		features['psychographic']['personas']['tertiary']['name'] = value
	end

	def personas_quartenary_name
		features['psychographic']['personas']['quartenary']['name'] if features['psychographic']
	end

	def personas_quartenary_name=(value)
		features['psychographic']['personas']['quartenary']['name'] = value
	end

	def personas_tertiary_score
		features['psychographic']['personas']['tertiary']['score'] if features['psychographic']
	end

	def personas_tertiary_score=(value)
		features['psychographic']['personas']['tertiary']['score'] = value
	end

	def personas_quartenary_score
		features['psychographic']['personas']['quartenary']['score'] if features['psychographic']
	end

	def personas_quartenary_score=(value)
		features['psychographic']['personas']['quartenary']['score'] = value
	end

	def personas_assortment_finished?
		features['psychographic']['personas']['assortment']['finished'] if features['psychographic']
	end

	def personas_assortment_finished=(value)
		features['psychographic']['personas']['assortment']['finished'] = value
	end

	def taste_events_save(event_id)
		event = Event.find event_id.to_i

		ActiveRecord::Base.transaction do
			event.entries['saved_by'] << id
			event.entries['total_saves'] += 1

			validate_taste_existence 'events'
			taste['events']['saved'] << event_id.to_i
			taste['events']['total_saves'] += 1

			return event.save && save
		end
	rescue ActiveRecord::RecordInvalid
		puts 'Não foi possível salvar sua ação (ERRO 7813)!'
	end

	def taste_events_unsave(event_id)
		event = Event.find event_id.to_i

		ActiveRecord::Base.transaction do
			event.entries['saved_by'].delete id
			event.entries['total_saves'] -= 1

			validate_taste_existence 'events'
			taste['events']['saved'].delete event_id.to_i
			taste['events']['total_saves'] -= 1

			return event.save && save
		end
	rescue ActiveRecord::RecordInvalid
		puts 'Não foi possível salvar sua ação (ERRO 7814)!'
	end

	def taste_events_saved?(event_id)
		if taste['events']
			taste['events']['saved'].include? event_id.to_i
		else
			false
		end
	end

	def taste_events_saved
		taste['events']['saved']
	end


	def self.from_omniauth(auth, guest_user, params)
		data  = auth.extra.id_info
		user  = User.where(email: data.email).first
		state = Base64.urlsafe_decode64(params['state'])

		Rails.logger.debug "PERSONAS STATE: #{state.inspect} "
		raise Exception, 'JSON de personas com enconding incorreto!' unless ['UTF-8', 'US-ASCII', 'ASCII-8BIT'].include? state.encoding.name

		@personas ||= begin
			YAML.safe_load(state)
		rescue Psych::SyntaxError
			{}
		end

		Rails.logger.debug "PERSONAS YAML: #{@personas.inspect} "
		Rails.logger.debug "GOOGLE DATA: #{data.inspect} "

		if @personas.empty?
			return user if user

			return User.create(email:    data.email,
			                   password: Devise.friendly_token[0, 20],
			                   features: {
					                   psychographic: guest_user.features['psychographic'],
					                   demographic:   {
							                   name:    data.name,
							                   picture: data.picture
					                   }
			                   })

		elsif @personas && @personas['assortment']['finished']
			features = {
					psychographic: {
							personas: {
									primary:    {
											name:  @personas['primary']['name'],
											score: @personas['primary']['score']
									},
									secondary:  {
											name:  @personas['secondary']['name'],
											score: @personas['secondary']['score']
									},
									tertiary:   {
											name:  @personas['tertiary']['name'],
											score: @personas['tertiary']['score']
									},
									quartenary: {
											name:  @personas['quartenary']['name'],
											score: @personas['quartenary']['score']
									},
									assortment: {
											finished:    @personas['assortment']['finished'],
											finished_at: @personas['assortment']['finished_at']
									}
							}
					},
					demographic:   {
							name:    data.name,
							picture: data.picture
					}
			}

			if user
				user if user.update_attributes(
						features: features
				)
			else
				User.create(email:    data.email,
				            password: Devise.friendly_token[0, 20],
				            features: features)
			end
		end
	end

	private

	def validate_taste_existence(dictionary = 'events')
		taste[dictionary] ||= {}

		if dictionary == 'events'
			taste[dictionary]['saved']          ||= []
			taste[dictionary]['liked']          ||= []
			taste[dictionary]['viewed']         ||= []
			taste[dictionary]['disliked']       ||= []
			taste[dictionary]['total_saves']    ||= 0
			taste[dictionary]['total_likes']    ||= 0
			taste[dictionary]['total_views']    ||= 0
			taste[dictionary]['total_dislikes'] ||= 0
		end
	end
end
