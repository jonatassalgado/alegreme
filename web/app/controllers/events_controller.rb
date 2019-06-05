class EventsController < ApplicationController
  before_action :authorize_admin, only: [:new, :edit, :create, :update, :destroy]
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :parse_ocurrences, only: [:update]
  before_action :parse_personas, only: [:update]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    respond_to do |format|
      format.html { render :show }
    end
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def retrain
    @event = Event.find params["event_id"]
    @feature = params[:feature]
    @type = params[:type]

    if @feature == "personas"
      @event.personas_outlier = params[:outlier] if params[:outlier]
      @event.personas_primary_name = params[:persona] if params[:persona]
      @event.personas_primary_score = 0.90 if params[:correct] || params[:persona]
    elsif @feature == "categories"
      @event.categories_outlier = params[:outlier] if params[:outlier]
      @event.categories_primary_name = params[:category] if params[:category]
      @event.categories_primary_score = 0.90 if params[:correct] || params[:category]
    elsif @feature == "themes"
      @event.theme_outlier = params[:outlier] if params[:outlier]
      @event.theme_name = params[:theme] if params[:theme]
      @event.theme_score = 0.90 if params[:correct] || params[:theme]
    elsif @feature == "kinds"
      @event.kinds = JSON.parse(params[:kinds]) if params[:kinds]
    elsif @feature == "tags"
      @event.public_send("tags_#{@type}=", JSON.parse(params[:tags])) 
    end

    respond_to do |format|
      if @event.update(retrain_params)
        if @feature == 'kinds'
          format.js { render 'layouts/classifier/kinds' }
        elsif ['personas', 'categories', 'themes'].include?(@feature)
          format.js { render 'layouts/classifier/chips' }
        elsif @feature == 'tags'
          format.js { render 'layouts/classifier/tags' }
        end
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  def parse_personas
    @event.personas["outlier"] = params[:event][:personas_outlier] || "false"
  end

  def parse_ocurrences
    params[:event][:ocurrences][:dates].each_with_index do |date, index|
      @event.ocurrences["dates"][index] = DateTime.parse(date).strftime("%Y-%m-%d %H:%M:%S")
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:name, :description, :url, :personas_primary_name, :personas_secondary_name, :personas_primary_score, :personas_secondary_score, :categories_primary_name, :categories_secondary_name, :categories_primary_score, :categories_secondary_score, :personas_outlier, :dates)
  end

  def retrain_params
    params.permit(:personas_primary_name, :personas_primary_score, :categories_primary_name, :categories_primary_score, :personas_outlier, :tags_things)
  end
end
