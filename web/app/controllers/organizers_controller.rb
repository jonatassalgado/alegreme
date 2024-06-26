class OrganizersController < ApplicationController
	before_action :authorize_admin, except: [:show, :hovercard]
	before_action :authorize_user, only: []
	before_action :set_organizer, only: [:show, :edit, :update, :destroy, :hovercard]

	# GET /organizers
	# GET /organizers.json
	def index
		@organizers = Organizer.order("(details ->> 'name')")
	end

	# GET /organizers/1
	# GET /organizers/1.json
	def show
		@pagy, @upcoming_events = pagy(@organizer.events.active)
		@past_events            = @organizer.events.past.order_by_date(direction: :desc)
	end

	# GET /organizers/new
	def new
		@organizer = Organizer.new
	end

	# GET /organizers/1/edit
	def edit
	end

	# POST /organizers
	# POST /organizers.json
	def create
		@organizer = Organizer.new(organizer_params)

		respond_to do |format|
			if @organizer.save
				format.html { redirect_to @organizer, notice: 'Organizer was successfully created.' }
				format.json { render :show, status: :created, location: @organizer }
			else
				format.html { render :new }
				format.json { render json: @organizer.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /organizers/1
	# PATCH/PUT /organizers/1.json
	def update
		respond_to do |format|
			if @organizer.update(organizer_params)
				format.html { redirect_to @organizer, notice: 'Organizer was successfully updated.' }
				format.json { render :show, status: :ok, location: @organizer }
			else
				format.html { render :edit }
				format.json { render json: @organizer.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /organizers/1
	# DELETE /organizers/1.json
	def destroy
		@organizer.destroy
		respond_to do |format|
			format.html { redirect_to organizers_url, notice: 'Organizer was successfully destroyed.' }
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

	def hovercard
		render layout: false
	end

	private

	# Use callbacks to share common setup or constraints between actions.
	def set_organizer
		if params[:id].numeric?
			@organizer = Organizer.friendly.find(params[:id])
			redirect_to organizer_path @organizer
		else
			@organizer = Organizer.friendly.find(params[:id])
		end
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def organizer_params
		params.require(:organizer).permit(:name, :url)
	end
end
