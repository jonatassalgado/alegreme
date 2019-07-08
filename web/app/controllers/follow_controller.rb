class FollowController < ApplicationController
	before_action :authorize_user

	def follow
		@type     = params[:type]
		@location = params[:location]

		followable  = resource_class
		association = FollowServices::AssociationCreator.new(current_user.id, followable).call

		if (@location == 'single-page')
			@user  = association.user
			@chips = Event.find(params[:event_id]).public_send(@type).sort

			render_component(association)
		end
	end

	def unfollow
		@type     = params[:type]
		@location = params[:location]

		followable  = resource_class
		association = FollowServices::AssociationCreator.new(current_user.id, followable).call(destroy: true)

		if (@location == 'single-page')
			@user  = association.user
			@chips = Event.find(params[:event_id]).public_send(@type).sort

			render_component(association)
		end
	end

	private

	def resource_class
		if @type == 'organizers'
			Organizer.find params[:resource_id]
		elsif @type == 'categories'
			Category.find params[:resource_id]
		end
	end

	def render_component(association)
		if association.saved?
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