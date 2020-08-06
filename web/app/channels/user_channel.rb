class UserChannel < ApplicationCable::Channel
	include CableReady::Broadcaster

	def subscribed
		stream_for current_user
	end

	def unsubscribed
		# Any cleanup needed when channel is unsubscribed
	end

	def taste(data)
		@save_button_html_id = data['body']['id']
		@html                = JSON.parse(data['body']['data-cable-ready-html'], {:symbolize_names => true})
		@opts                = JSON.parse(data['body']['data-cable-ready-opts'], {:symbolize_names => true})
		@resource_id         = data['body']['data-cable-ready-resource-id'].to_i
		@resource_type       = data['body']['data-cable-ready-resource-type']
		@action              = data['body']['data-cable-ready-action']
		@resource_html_id    = data['body']['data-cable-ready-resource-html-id']
		@saves_html_id       = data['body']['data-cable-ready-collection-html-id']
		@taste_type          = data['body']['data-cable-ready-taste-type']
		@taste_sentiment     = data['body']['data-cable-ready-taste-sentiment'].to_sym
		@resource            = @resource_type.classify.constantize.find @resource_id
		@user                = current_user

		taste_status = @user.public_send("taste_#{@resource_type}_#{@action}", @resource)

		if @taste_sentiment == :positive && UserDecorators::Taste::TASTE_ACTIONS.map { |key, value| value[:add] }.include?(taste_status)
			cable_ready[UserChannel].add_css_class(
					selector: "##{@resource_html_id} [data-cable-ready-taste-sentiment='negative']",
					name:     "hidden"
			)
		elsif @taste_sentiment == :negative && UserDecorators::Taste::TASTE_ACTIONS.map { |key, value| value[:add] }.include?(taste_status)
			cable_ready[UserChannel].add_css_class(
					selector: "##{@resource_html_id} [data-cable-ready-taste-sentiment='positive']",
					name:     "hidden"
			)
		else
			cable_ready[UserChannel].remove_css_class(
					selector: "##{@resource_html_id} [data-cable-ready-taste-sentiment='positive']",
					name:     "hidden"
			)
			cable_ready[UserChannel].remove_css_class(
					selector: "##{@resource_html_id} [data-cable-ready-taste-sentiment='negative']",
					name:     "hidden"
			)
		end

		update_save_button
		hidden_resource_node if @opts[:remove_on_action] && ['dislike', 'save'].include?(@action)
		update_saves_collection if @opts[:update_collection_on_action]

		cable_ready.broadcast_to(@user, UserChannel)
	end

	private

	def update_save_button
		if @save_button_html_id
			cable_ready[UserChannel].morph(
					selector:      "##{@save_button_html_id}",
					html:          ApplicationController.render(partial: 'components/taste_button',
					                                            locals:  {
							                                            user:            @user,
							                                            resource:        @resource,
							                                            parent_id:       @resource_html_id,
							                                            taste_type:      @taste_type,
							                                            taste_sentiment: @taste_sentiment,
							                                            html:            @html,
							                                            opts:            @opts
					                                            }),
					children_only: false
			)
		end
	end

	def update_saves_collection
		if @opts[:update_collection_on_action] && @resource_type
			saved_resources = @user.public_send("saved_#{@resource_type}").active.order_by_date

			if saved_resources.present?
				cable_ready[UserChannel].remove_css_class(
						selector: "##{@saves_html_id}",
						name:     "hidden"
				)
				cable_ready[UserChannel].morph(
						selector:      "##{@saves_html_id}",
						html:          ApplicationController.render(partial: "components/#{@resource_type}/saves",
						                                            locals:  {
								                                            user:            @user,
								                                            identifier:      "#{@saves_html_id}",
								                                            saved_resources: saved_resources
						                                            }),
						children_only: true
				)
			else
				cable_ready[UserChannel].add_css_class(
						selector: "##{@saves_html_id}",
						name:     "hidden"
				)
			end
		end
	end

	def hidden_resource_node
		if @opts[:remove_on_action] && @resource_html_id
			cable_ready[UserChannel].add_css_class(
					selector: "##{@resource_html_id}",
					name:     "hidden"
			)
		end
	end

end
