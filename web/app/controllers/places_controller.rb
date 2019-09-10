class PlacesController < ApplicationController
	before_action :authorize_admin, except: :show
	before_action :set_place, only: [:show, :edit, :update, :destroy]

	# GET /places
	# GET /places.json
	def index
		@places = Place.all
	end

	# GET /places/1
	# GET /places/1.json
	def show
		# respond_to do |format|
			# format.js do
			# 	# Rails.cache.fetch("#{current_or_guest_user}_user_personas", expires_in: 1.hour) do
			# 	events      = @place.events.active
			# 	@collection = EventServices::CollectionCreator.new(current_or_guest_user, params).call(events, places: [params[:id]])
			# 	# end
			#
			# 	@locals = mount_section_attrs
			# 	render 'collections/index'
			# end
			# format.html do
				# Rails.cache.fetch("#{current_or_guest_user}_user_personas", expires_in: 1.hour) do
				events      = @place.events.active
				@collection = EventServices::CollectionCreator.new(current_or_guest_user, params).call(events, places: [params[:id]])

				@locals = mount_section_attrs
				render 'show'
				# end
		# 	end
		# end
	end

	# GET /places/new
	def new
		@place = Place.new
	end

	# GET /places/1/edit
	def edit
	end

	# POST /places
	# POST /places.json
	def create
		@place = Place.new(place_params)

		respond_to do |format|
			if @place.save
				format.html { redirect_to @place, notice: 'Place was successfully created.' }
				format.json { render :show, status: :created, location: @place }
			else
				format.html { render :new }
				format.json { render json: @place.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /places/1
	# PATCH/PUT /places/1.json
	def update
		respond_to do |format|
			if @place.update(place_params)
				format.html { redirect_to @place, notice: 'Place was successfully updated.' }
				format.json { render :show, status: :ok, location: @place }
			else
				format.html { render :edit }
				format.json { render json: @place.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /places/1
	# DELETE /places/1.json
	def destroy
		@place.destroy
		respond_to do |format|
			format.html { redirect_to places_url, notice: 'Place was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private

	def mount_section_attrs
		{
				items:      @collection,
				title:      {
						principal: @place.details_name,
            secondary: @place.geographic_address
				},
				identifier: @place.details_name.parameterize,
				opts:       {
						filters: {
								ocurrences: true,
								kinds:      true,
								categories: true
						},
						detail:  @collection[:detail],
				}
		}
	end

	# Use callbacks to share common setup or constraints between actions.
	def set_place
		@place = Place.friendly.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def place_params
		params.require(:place).permit(:name, :address)
	end
end
