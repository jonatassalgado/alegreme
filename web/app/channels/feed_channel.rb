class FeedChannel < ApplicationCable::Channel
	include CableReady::Broadcaster

	def subscribed
		stream_from "feed_channel"
	end

	def unsubscribed
		# Any cleanup needed when channel is unsubscribed
	end

	def receive(data)
		save_status  = current_user.public_send("taste_#{data['body']['resource']}_#{data['body']['action']}", data['body']['id'].to_i)
		saved_events = current_user.public_send("saved_#{data['body']['resource']}").active.order_by_date

		if data['body']['selector'].present?
			cable_ready["feed_channel"].remove(
					selector: "##{data['body']['selector']}"
			)

			cable_ready["feed_channel"].morph(
					selector:      "##{data['body']['resource']}_saved",
					html:          ApplicationController.render(partial: 'feeds/saves',
					                                            locals:  {
							                                            user:            current_user,
							                                            identifier:      "#{data['body']['resource']}_saved",
							                                            saved_resources: saved_events,
							                                            empty_message:   "Salve com ❤ para vê - los aqui"
					                                            }),
					children_only: false
			)

			cable_ready.broadcast
		else
			transmit({status: save_status})
		end

	end
end
