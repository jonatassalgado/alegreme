class AdsenseController < ApplicationController

	include ActionView::RecordIdentifier

	def square
		render partial: 'adsense/square', locals: { id: 'events-show' }
	end

end
