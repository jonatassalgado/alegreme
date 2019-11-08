class UsersController < ApplicationController
	before_action :set_user, only: %i[show edit update destroy]
	before_action :authorize_admin, only: [:index, :destroy, :edit, :update]
	before_action :authorize_current_user, only: %i[show]
	before_action :mount_json, only: %i[edit update]

	def active_invite
		@user = User.find_by_reset_password_token params[:reset_password_token]

		if @user.has_permission_to_login?
			redirect_to edit_user_password_path(reset_password_token: params[:reset_password_token])
		else
			redirect_to root_path, notice: 'Seu convite parece não ser válido'
		end
	end

	# GET /users
	# GET /users.json
	def index
		@users = User.order("created_at DESC")
	end

	# GET /users/1
	# GET /users/1.json
	def show
		events      = @user.saved_events(as_model: true)
		@topics     = @user.following_topics
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'current_user.slug',
				                                                                              events:     events
		                                                                              }, {
				                                                                              with_high_score: false,
				                                                                              not_in_saved:    false,
				                                                                              only_in:         events.map(&:id),
				                                                                              limit:           24
		                                                                              })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Eventos salvos por você",
						secondary: "Esta é a sua lista de eventos que ainda não aconteceram"
				},
				identifier: "user-saved-events",
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

	# GET /users/new
	def new
		@user = User.new
	end

	# GET /users/1/edit
	def edit
	end

	# POST /users
	# POST /users.json
	def create
		@user = User.new(user_params)

		respond_to do |format|
			if @user.save
				format.html { redirect_to @user, notice: 'User was successfully created.' }
				format.json { render :show, status: :created, location: @user }
			else
				format.html { render :new }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /users/1
	# PATCH/PUT /users/1.json
	def update
		respond_to do |format|
			if @user.update(user_params)
				format.html { redirect_to feed_path, notice: 'User was successfully updated.' }
				format.json { render json: @user, status: :ok }
			else
				format.html { render :edit }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /users/1
	# DELETE /users/1.json
	def destroy
		@user.destroy
		respond_to do |format|
			format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private

	# Use callbacks to share common setup or constraints between actions.
	def set_user
		@user = if params[:id]
			        User.friendly.find(params[:id])
			      else
				      current_user
		        end
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
		params.require(:user).permit(:name,
		                             :id,
		                             :personas_primary_name,
		                             :personas_primary_score,
		                             :personas_secondary_name,
		                             :personas_secondary_score,
		                             :personas_tertiary_name,
		                             :personas_tertiary_score,
		                             :personas_quartenary_name,
		                             :personas_quartenary_score,
		                             :personas_assortment_finished,
		                             :personas_assortment_finished_at,
		                             :notifications_devices,
		                             :notifications_topics => {
				                             :all => [
						                             :requested,
						                             :active
				                             ]
		                             })
	end

	def mount_json
		if @user.features.empty?
			@user.features = {
					psychographic: {
							personas: {
									primary:    {
											name:  nil,
											score: nil
									},
									secondary:  {
											name:  nil,
											score: nil
									},
									tertiary:   {
											name:  nil,
											score: nil
									},
									quartenary: {
											name:  nil,
											score: nil
									}
							}
					}
			}
		end
	end
end
