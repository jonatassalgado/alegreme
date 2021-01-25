class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:index, :show]
  before_action :authorize_admin, only: [:admin, :destroy]
  before_action :authorize_current_user, only: [:update, :edit]

  def active_invite
    @user = User.find_by_reset_password_token params[:reset_password_token]

    if @user.has_permission_to_login?
      redirect_to edit_user_password_path(reset_password_token: params[:reset_password_token])
    else
      redirect_to root_path, notice: 'Seu convite parece não ser válido'
    end
  end

  def admin
    @users = User.order("created_at DESC")
    render 'users/admin/index'
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.recents
    render 'users/index'
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @upcoming_events = @user&.liked_events&.not_ml_data&.active&.order_by_date
    @past_events     = @user&.liked_events&.not_ml_data&.past&.order("updated_at DESC")
    @current_user    = current_user

    @friend ||= nil
    @sheet  ||= nil

    render layout: false if @stimulus_reflex
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
    if current_or_guest_user.admin?
      respond_to do |format|
        format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  def agenda
    @liked_events = current_user ? current_user&.liked_events&.not_ml_data&.active&.order_by_date : Event.none
    render layout: false if @stimulus_reflex
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
    if current_user.admin?
      params.require(:user).permit(:name,
                                   :id,
                                   :slug,
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
    else
      params.require(:user).permit(:name, :image, :slug)
    end

  end

end
