module Api
	class TasteController < ApplicationController
		before_action :authorize_user

		def update

			return unless ["save", "like", "view", "dislike", "unsave", "unlike", "unview", "undislike"].include?(taste_params[:taste])

			entity = taste_params[:resource].classify.constantize.find taste_params[:id].to_i

			if entity
				if taste_params[:swipable]
					current_user.swipable.deep_merge!({
							                                  'events' => {
									                                  'last_view_at' => DateTime.now
							                                  }
					                                  })
				end

				current_user.public_send("taste_#{taste_params[:resource]}_#{taste_params[:taste]}", entity.id)

				respond_to do |format|
					format.js { render 'favorites/favorites' }
					format.json {
						render json: {
								taste_params[:taste] => :success
						}
					}
				end
			else
				respond_to do |format|
					format.json {
						render json: {
								taste_params[:taste] => :fail
						}
					}
				end
			end
		end

		# def destroy
		# 	current_user.taste_events_unsave taste_params['event_id'].to_i
		#
		# 	@data = {
		# 			identifier:              'salvos',
		# 			event_identifier:        "event_#{taste_params['event_id'].to_i}",
		# 			event_id:                taste_params['event_id'].to_i,
		# 			user:                    current_user,
		# 			current_event_favorited: false,
		# 			liked_events:            current_user.liked_events,
		# 			json_request:            true
		# 	}
		#
		# 	respond_to do |format|
		# 		format.js { render 'favorites/favorites' }
		# 	end
		# end

		private

		# Never trust parameters from the scary internet, only allow the white list through.
		def taste_params
			params.permit(:id, :resource, :taste, :swipable)
		end
	end
end
