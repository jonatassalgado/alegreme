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

		events      = @place.events
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'places',
				                                                                              events:     events
		                                                                              }, {
				                                                                              in_places:       [params[:id]],
				                                                                              with_high_score: false,
				                                                                              in_user_personas: false,
				                                                                              order_by_persona: false,
				                                                                              order_by_date:    true,
				                                                                              limit:           24
		                                                                              })

		@data = {
				identifier: @place.details_name.parameterize,
				collection: @collection,
				title:      {
						principal: @place.details_name,
						secondary: @place.geographic_address
				},
				followable: @place,
				filters:    {
						ocurrences: true,
						kinds:      true,
						categories: true
				}
		}

		render 'show'

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

	# Use callbacks to share common setup or constraints between actions.
	def set_place
		if params[:id].numeric?
			@place = Place.friendly.find(params[:id])
			redirect_to place_path @place
		else
			@place = Place.friendly.find(params[:id])
		end
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def place_params
		params.require(:place).permit(:name, :address)
	end
end
