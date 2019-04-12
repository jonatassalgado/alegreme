class EventsController < ApplicationController
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
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
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
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
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
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    def parse_personas
      @event.personas['outlier'] = params[:event][:personas_outlier] || 'false'
    end

    def parse_ocurrences
      params[:event][:ocurrences][:dates].each_with_index do |date, index|
        @event.ocurrences['dates'][index] = DateTime.parse(date).strftime("%Y-%m-%d %H:%M:%S")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :description, :url, :personas_primary_name, :personas_secondary_name, :personas_primary_score, :personas_secondary_score, :categories_primary_name, :categories_secondary_name, :categories_primary_score, :categories_secondary_score, :personas_outlier, :dates)
    end
end
