class FollowController < ApplicationController
	before_action :authorize_user

	def follow
		parse_params

		@association = FollowServices::AssociationCreator.new(current_user.id, get_followable).call
		@topics      = get_topics
		@data        = mount_locals

		render_component
	end

	def unfollow
		parse_params

		@association = FollowServices::AssociationCreator.new(current_user.id, get_followable).call(destroy: true)
		@topics      = get_topics
		@data        = mount_locals

		render_component
	end

	private

	def follow_params
		params.permit(:identifier, :user, :event_id, :type, :expand_to_similar, :resource_id, :follow)
	end

	def parse_params
		@user              = follow_params[:user] ? JSON.parse(follow_params[:user]) : nil
		@expand_to_similar = follow_params[:expand_to_similar] ? JSON.parse(follow_params[:expand_to_similar]) : false
		@event_id          = follow_params[:event_id] ? JSON.parse(follow_params[:event_id]) : nil
		@identifier        = follow_params[:identifier]
		@type              = follow_params[:type]
	end

	def mount_locals
		{
				identifier:        @identifier || "follow-chip-set__#{@type}-#{@event_id}",
				user:              current_user,
				event_id:          follow_params[:event_id],
				chips:             @topics,
				type:              @type,
				expand_to_similar: follow_params[:expand_to_similar] ? @expand_to_similar : false
		}
	end

	def get_followable
		if @type == 'organizers'
			Organizer.find follow_params[:resource_id]
		elsif @type == 'places'
			Place.find follow_params[:resource_id]
		end
	end


	def get_topics
		if @expand_to_similar && @event_id
			similar_events_ids = Event.find(follow_params[:event_id]).similar_data[0...6]
			similar_events     = Event.where(id: similar_events_ids).active.not_in_saved(current_user)
			return similar_events.map { |similar| similar.organizers[0..6] }.flatten.uniq[0..6].sort
		end

		if @event_id
			return Event.find(follow_params[:event_id]).public_send(@type).sort
		end

		if @user
			current_user.following_topics
		end
	end


	def render_component

		respond_to do |format|
			format.js { render 'follow/chip-set' }
			format.json { render json: @association }
		end
	end

end
