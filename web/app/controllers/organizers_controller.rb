class OrganizersController < ApplicationController
	before_action :authorize_admin, except: :show
	before_action :set_organizer, only: [:show, :edit, :update, :destroy]

	# GET /organizers
	# GET /organizers.json
	def index
		@organizers = Organizer.order("(details ->> 'name')")
	end

	# GET /organizers/1
	# GET /organizers/1.json
	def show

		respond_to do |format|
			format.js do
				# Rails.cache.fetch("#{current_or_guest_user}_user_personas", expires_in: 1.hour) do
					events      = @organizer.events.active
					@collection = EventServices::CollectionCreator.new(current_or_guest_user, params).call(events, organizers: [params[:id]], limit: 20)
				# end

				@locals = mount_section_attrs
				render 'collections/index'
			end
			format.html do
				# Rails.cache.fetch("#{current_or_guest_user}_user_personas", expires_in: 1.hour) do
					events      = @organizer.events.active
					@collection = EventServices::CollectionCreator.new(current_or_guest_user, params).call(events, organizers: [params[:id]], limit: 20)

					@locals = mount_section_attrs
					render 'show'
				# end
			end
		end

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

	private

	def mount_section_attrs
		{
				items:      @collection,
				title:     {
						principal: @organizer.details['name']
				},
				identifier: @organizer.details['name'].parameterize,
				opts: {
						filters:    {
								ocurrences: true,
								kinds:      true,
								categories: true
						},
						detail: @collection[:detail]
				}
		}
	end

	# Use callbacks to share common setup or constraints between actions.
	def set_organizer
		@organizer = Organizer.friendly.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def organizer_params
		params.require(:organizer).permit(:name, :url)
	end
end
