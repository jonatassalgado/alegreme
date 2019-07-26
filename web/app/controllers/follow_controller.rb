class FollowController < ApplicationController
	before_action :authorize_user

	def follow
		fetch_params

		@association = FollowServices::AssociationCreator.new(current_user.id, get_followable).call
		@topics      = get_topics
		@locals      = mount_locals

		render_component
	end

	def unfollow
		fetch_params

		@association = FollowServices::AssociationCreator.new(current_user.id, get_followable).call(destroy: true)
		@topics      = get_topics
		@locals      = mount_locals

		render_component
	end

	private

	def mount_locals
		{
				user:              current_user,
				event_id:          @event_id,
				chips:             @topics,
				type:              @type,
				expand_to_similar: @expand_to_similar
		}
	end

	def fetch_params
		@event_id          = params[:event_id]
		@type              = params[:type]
		@location          = params[:location]
		@expand_to_similar = JSON.parse params[:expand_to_similar]
	end

	def get_followable
		if params[:type] == 'organizers'
			Organizer.find params[:resource_id]
		elsif params[:type] == 'categories'
			Category.find params[:resource_id]
		end
	end


	def get_topics
		if @expand_to_similar
			similar_events_ids = Event.find(@event_id).similar_data[0...6]
			similar_events     = Event.where(id: similar_events_ids).not_in_saved(current_user)
			similar_events.map { |similar| similar.organizers[0..6] }.flatten.uniq[0..6].sort
		else
			Event.find(@event_id).public_send(@type).sort
		end
	end


	def render_component
		if @association.saved?
			respond_to do |format|
				format.js { render 'follow/chip-set' }
			end
		else
			respond_to do |format|
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

end