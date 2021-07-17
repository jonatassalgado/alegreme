class MoviesController < ApplicationController
	before_action :authorize_admin, except: [:show]

	def index

		@movies       = CineFilm.includes(:cinemas, :screenings).all
		@saved_movies = current_user.try(:saved_movies)
		@movies_group = [
			{
				:identifier => 'editors-choice',
				:title      => "Escolha dos editores",
				:items      => @movies.filter { |movie| movie.collections.include? "editors choice" }
			}
		]

		Movie::GENRES.each_with_index do |genre, index|
			@movies_group << {
				:identifier => genre.parameterize,
				:title      => genre,
				:items      => @movies.filter { |movie| movie.details["genres"].include? genre }.sort.slice(0..16)
			}
		end
	end

	def show
		model    = get_model(params[:type])
		@movie   = model.includes(:cinemas, :screenings).friendly.find(params[:id])
		@movies  = CineFilm.includes(:cinemas, :screenings).active
		@cinemas = Cinema.includes(:movies, :screenings).where("screenings.movie_id = ? AND screenings.day >= ?", @movie.id, Date.current).order("screenings.day ASC").uniq

		respond_to do |format|
			format.html { render :show }
		end
	end

	def new
		model  = get_model(params[:type])
		@movie = model.new
		@movie.build_streamings
		@movie.build_collections
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
		model  = get_model(params[:type])
		@movie = model.friendly.find(params[:id])

		@movie.destroy
		respond_to do |format|
			format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private

	def get_model type
		if type
			return type.classify.constantize
		else
			Movie
		end
	end

	def model_params
		model = params[:type] ? params[:type].underscore.to_sym : :movie

		params.require(model).permit(
			:image,
			:details_original_title,
			:details_title,
			:details_genres,
			:description,
			:details_cover,
			:details_trailler,
			:details_popularity,
			:details_vote_average,
			:details_adult,
			:details_tmdb_id,
			:type,
			streamings_attributes:  [:display_name, :url],
			collections_attributes: [])
	end
end
