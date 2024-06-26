class PlacesController < ApplicationController
	before_action :authorize_admin, except: [:show, :follow, :unfollow]
	before_action :authorize_user, only: [:follow, :unfollow]
	before_action :set_place, only: [:show, :edit, :update, :destroy]

	# GET /places
	# GET /places.json
	def index
		@places = Place.all
	end

	# GET /places/1
	# GET /places/1.json
	def show
		@pagy, @upcoming_events = pagy(@place.events.includes(:organizers, :events_organizers).active.order_by_date)
		@past_events            = @place.events.past.order_by_date(direction: :desc)
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

	def follow
		@association = FollowServices::AssociationCreator.new(current_user, params[:id], controller_name).call
		render layout: false
	end

	def unfollow
		@association = FollowServices::AssociationCreator.new(current_user, params[:id], controller_name).call(destroy: true)
		render layout: false
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
