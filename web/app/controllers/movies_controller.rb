class MoviesController < ApplicationController
	before_action :authorize_admin, only: [:new, :edit, :create, :update, :destroy]

	def index
		# @movies = Movie.select("*").from(Movie.select("*, jsonb_array_elements(dates) as date")).where("(date ->> 'date') > ?", DateTime.now.beginning_of_day).uniq
		# @movies = Movie.where("created_at > :time", time: DateTime.now - 30).order("(details ->> 'vote_average')::numeric DESC")
		@movies = Movie.where("created_at > :time AND jsonb_array_length(streamings::jsonb) > 0", time: DateTime.now - 30).order("(details ->> 'vote_average')::numeric DESC")
	end

	def show
		model  = get_model(params[:type])
		@movie = model.friendly.find(params[:id])

		respond_to do |format|
			format.html { render :show }
		end
	end

	def new
		model  = get_model(params[:type])
		@movie = model.new
		@movie.build_streaming
	end

	# GET /movies/1/edit
	def edit
		model  = get_model(params[:type])
		@movie = model.friendly.find(params[:id])
	end

	# POST /movies
	# POST /movies.json
	def create
		model  = get_model(params[:type])
		@movie = model.new(model_params)

		respond_to do |format|
			if @movie.save
				format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
				format.json { render :show, status: :created, location: @movie }
			else
				format.html { render :new }
				format.json { render json: @movie.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /movies/1
	# PATCH/PUT /movies/1.json
	def update
		model       = get_model(params[:type])
		@movie      = model.friendly.find(params[:id])
		@movie.slug = nil

		respond_to do |format|
			if @movie.update(model_params)
				format.html { redirect_to send("edit_#{@movie.type.underscore}_path", @movie), notice: 'Movie was successfully updated.' }
				format.json { render json: @movie, status: :ok }
			else
				format.html { render :edit }
				format.json { render json: @movie.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /movies/1
	# DELETE /movies/1.json
	def destroy
		model       = get_model(params[:type])
		@movie      = model.friendly.find(params[:id])

		@movie.destroy
		respond_to do |format|
			format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
			format.json { head :no_content }
		end
	end


	private


	def get_model type
     return type.classify.constantize
  end

	def model_params
		logger.debug params[:type].underscore.to_sym
		params.require(params[:type].underscore.to_sym).permit(
			:details_original_title,
			:details_title,
			:details_genres,
			:details_description,
			:details_cover,
			:details_trailler,
			:details_popularity,
			:details_vote_average,
			:details_adult,
			:details_tmdb_id,
		  streamings_attributes: [:display_name, :url])
		end
end
