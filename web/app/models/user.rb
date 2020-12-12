class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable
	devise :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

	validates :name, :length => { :in => 3..60 }
	validates :email, uniqueness: true
	validates :slug, uniqueness: true

	extend FriendlyId
	friendly_id :name, use: :slugged

	include UserImageUploader::Attachment.new(:image)
	# include UserDecorators::Following
	# include UserDecorators::Taste
	include UserDecorators::Personas
	include UserDecorators::Demographic
	include UserDecorators::Omniauth
	include UserDecorators::Permissions
	include UserDecorators::Requirements
	include UserDecorators::Suggestions
	include UserDecorators::Notifications

	has_many :likes, dependent: :destroy
	has_many :liked_or_disliked_events, through: :likes, source: :event
	has_many :liked_events, -> { where(likes: { sentiment: :positive }) }, through: :likes, source: :event
	has_many :disliked_events, -> { where(likes: { sentiment: :negative }) }, through: :likes, source: :event

	has_many :friendships, dependent: :destroy
	has_many :friendships_requested, -> { where(status: :requested) }, foreign_key: :user_id, class_name: 'Friendship'
	has_many :friendships_request_received, -> { where(status: :requested) }, foreign_key: :friend_id, class_name: 'Friendship'
	# has_many :friendships_accepted, -> (user) { where(status: :accepted).where("user_id = :user_id OR friend_id = :user_id", user_id: user.id) }, class_name: 'Friendship'

	has_many :friends_requested, through: :friendships_requested, source: :friend
	has_many :friends_requested_received, through: :friendships_request_received, source: :user
	# has_many :friends_accepted, -> (user) {User.joins("LEFT JOIN friendships ON friendships.user_id = users.id OR friendships.friend_id = users.id").where("users.id != :user_id AND friendships.status = 1", user_id: user.id)}
	# has_many :friends_accepted, through: :friendships_accepted, source: :friend

	def friendships_accepted
		Friendship.where("user_id = :user_id OR friend_id = :user_id  AND friendships.status = 1", user_id: self.id)
	end

	def friends_accepted
		User.joins("LEFT JOIN friendships ON friendships.user_id = users.id OR friendships.friend_id = users.id").where("users.id != :user_id AND friendships.status = 1", user_id: self.id)
	end

	has_many :follows, dependent: :destroy
	has_many :following_relationships, foreign_key: :user_id, class_name: 'Follow'
	has_many :following_users, through: :following_relationships, source: :following, source_type: 'User'
	has_many :following_places, through: :following_relationships, source: :following, source_type: 'Place'
	has_many :following_organizers, through: :following_relationships, source: :following, source_type: 'Organizer'
	has_many :following_places_events, through: :following_places, source: :events
	has_many :following_organizers_events, through: :following_organizers, source: :events
	has_many :following_users_events, -> { where(likes: { sentiment: :positive }) }, through: :likes, source: :event

	has_many :places_from_liked_events, through: :liked_events, source: :place
	has_many :organizers_from_liked_events, through: :liked_events, source: :organizers

	def following
		following_users + following_places + following_organizers
	end

	def following_places_and_organizers
		following_places + following_organizers
	end

	def following_events
		Event.where(id: [following_users_event_ids, following_places_event_ids, following_organizers_event_ids].flatten.uniq)
	end

	def resources_from_liked_events
		places_from_liked_events + organizers_from_liked_events
	end

	def like!(event, action: :create)
		if action == :create
			self.likes.create!(event_id: event.id, sentiment: :positive)
			self.liked_events.reset
		elsif action == :update
			self.like_update(event, sentiment: :positive)
			self.liked_events.reset
			self.disliked_events.reset
		end
		UpdateUserEventsSuggestionsJob.perform_later(self.id)
	end

	def unlike!(event)
		like = self.likes.find_by(event_id: event.id)
		like.destroy
		self.liked_events.reset
		self.disliked_events.reset
	end

	def dislike!(event, action: :create)
		if action == :create
			self.likes.create!(event_id: event.id, sentiment: :negative)
			self.disliked_events.reset
		elsif action == :update
			self.like_update(event, sentiment: :negative)
			self.liked_events.reset
			self.disliked_events.reset
		end
	end

	def like_or_dislike?(event)
		self.likes.exists?(event_id: event.id)
	end

	def like_update(event, values)
		event_to_update = self.likes.find_by(event_id: event.id)
		event_to_update.update(values) if event_to_update
	end

	def like?(event)
		self.liked_event_ids.include?(event.id)
	end

	def dislike?(event)
		self.disliked_event_ids.include?(event.id)
	end

	def follow!(following)
		self.follows.create!(user_id: self.id, following_id: following.id, following_type: following.class.name)
	end

	def unfollow!(following)
		follow = self.follows.find_by(user_id: self.id, following_id: following.id, following_type: following.class.name)
		follow.destroy!
	end

	def follow?(following)
		self.following_relationships.exists?(following_id: following.id)
	end

	def friendship_request!(friend)
		Friendship.create!(user_id: self.id, friend_id: friend.id, friend_type: 'Friend', status: :requested)
	end

	def friendship_destroy!(friend)
		friendship = Friendship.find_by(user_id: [self.id, friend.id], friend_id: [friend.id, self.id], friend_type: 'Friend')
		friendship.destroy!
		friendship.destroyed?
	end

	def friendship_accept!(friend)
		friendship = Friendship.find_by(user_id: [self.id, friend.id], friend_id: [friend.id, self.id], friend_type: 'Friend', status: :requested)
		friendship.accepted!
	end

	def friendship_refused!(friend)
		friendship = Friendship.find_by(user_id: [self.id, friend.id], friend_id: [friend.id, self.id], friend_type: 'Friend', status: :requested)
		friendship.refused!
	end

	def friendship?(friend)
		Friendship.exists?(user_id: [self.id, friend.id], friend_id: [friend.id, self.id], friend_type: 'Friend')
	end

	def friendship_accepted?(friend)
		Friendship.exists?(user_id: [self.id, friend.id], friend_id: [friend.id, self.id], friend_type: 'Friend', status: :accepted)
	end

	def friendship_requested?(friend)
		Friendship.exists?(user_id: self.id, friend_id: friend.id, friend_type: 'Friend', status: :requested)
	end

	def friendship_request_received?(friend)
		Friendship.exists?(user_id: friend.id, friend_id: self.id, friend_type: 'Friend', status: :requested)
	end

	scope 'recents', lambda {
		where("last_sign_in_at > ?", Date.today - 60.days).order("last_sign_in_at DESC")
	}

	scope 'with_saved_events', lambda {
		where("jsonb_array_length(taste -> 'events' -> 'saved') > 0")
	}

	scope 'with_notifications_actived', lambda {
		where("(notifications -> 'topics' -> 'all' ->> 'active')::boolean")
	}

	def remember_me
		true
	end

	private

	def validate_taste_existence(dictionary = :events)
		_dictionary        = dictionary.to_s
		taste[_dictionary] ||= {}

		if _dictionary == :events
			taste[_dictionary]['saved']          ||= []
			taste[_dictionary]['liked']          ||= []
			taste[_dictionary]['viewed']         ||= []
			taste[_dictionary]['disliked']       ||= []
			taste[_dictionary]['total_saves']    ||= 0
			taste[_dictionary]['total_likes']    ||= 0
			taste[_dictionary]['total_views']    ||= 0
			taste[_dictionary]['total_dislikes'] ||= 0
			taste[_dictionary]['updated_at']     ||= DateTime.now
		end
	end
end
